# rides/views.py

from rest_framework import generics, viewsets, status, permissions, filters
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db import models, transaction as db_transaction
from django.utils import timezone
from math import radians, cos, sin, asin, sqrt, ceil
from decimal import Decimal, InvalidOperation
from datetime import timedelta
from django.core.cache import cache
import random

from .models import (
    User, ParkingZone, Bike, Ride, Wallet, Transaction, SupportTicket,
    Pass, UserPass, BikeReport, CorporateAccount
)
from .serializers import (
    RegisterSerializer, UserSerializer, ParkingZoneSerializer,
    BikeSerializer, RideSerializer, WalletSerializer, TransactionSerializer,
    SupportTicketSerializer, PassSerializer, UserPassSerializer, BikeReportSerializer,
    UserProfileUpdateSerializer, CorporateAccountSerializer, AdminUserSerializer,
    AdminBikeSerializer, AdminRideSerializer, AdminSupportTicketSerializer
)

def haversine(lon1, lat1, lon2, lat2):
    lon1, lat1, lon2, lat2 = map(radians, [float(lon1), float(lat1), float(lon2), float(lat2)])
    dlon, dlat = lon2 - lon1, lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    return (c * 6371) * 1000

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        otp_code = str(random.randint(1000, 9999))
        cache.set(f"otp_{user.id}", otp_code, timeout=300)
        print(f"--- GARA BIKE OTP for {user.email}: {otp_code} ---")
        return Response({"message": "User created. Please verify OTP."}, status=status.HTTP_201_CREATED)

@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def verify_otp(request):
    email, otp = request.data.get('email'), request.data.get('otp')
    if not email or not otp: return Response({"error": "Email and OTP required."}, status=status.HTTP_400_BAD_REQUEST)
    user = get_object_or_404(User, email=email)
    stored_otp = cache.get(f"otp_{user.id}")
    if stored_otp == otp:
        user.is_active, user.is_verified = True, True
        user.save()
        cache.delete(f"otp_{user.id}")
        return Response({"message": "Account verified successfully."}, status=status.HTTP_200_OK)
    return Response({"error": "Invalid OTP."}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_active_reservation(request):
    try:
        reserved_bike = Bike.objects.get(reserved_by=request.user, status='RESERVED')
        if reserved_bike.reservation_expires_at and timezone.now() < reserved_bike.reservation_expires_at:
            return Response(BikeSerializer(reserved_bike).data)
        else:
            reserved_bike.status, reserved_bike.reserved_by, reserved_bike.reservation_expires_at = 'AVAILABLE', None, None
            reserved_bike.save()
            return Response(status=status.HTTP_404_NOT_FOUND)
    except Bike.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_active_ride(request):
    """
    Checks if the current user has an active (un-ended) ride and returns it.
    """
    try:
        active_ride = Ride.objects.get(user=request.user, end_time__isnull=True)
        serializer = RideSerializer(active_ride)
        return Response(serializer.data)
    except Ride.DoesNotExist:
        # This is an expected case, not an error.
        return Response(status=status.HTTP_404_NOT_FOUND)

class BikeViewSet(viewsets.ModelViewSet):
    serializer_class = BikeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # This queryset is now less restrictive. It gets all bikes.
        # Filtering by status is now handled in the specific action (e.g., list).
        return Bike.objects.filter(latitude__isnull=False, longitude__isnull=False)

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset().filter(status='AVAILABLE') # Filter for available bikes only when listing
        zone_id = self.request.query_params.get('zone_id')
        if zone_id:
            try:
                zone = ParkingZone.objects.get(id=zone_id, is_active=True)
                bike_ids = [b.id for b in queryset if haversine(zone.longitude, zone.latitude, b.longitude, b.latitude) <= zone.radius]
                queryset = self.get_queryset().filter(id__in=bike_ids)
            except (ParkingZone.DoesNotExist, ValueError):
                return Response([])
        
        lat, lon = request.query_params.get('lat'), request.query_params.get('lon')
        if lat and lon:
            try:
                user_lat, user_lon = float(lat), float(lon)
                bikes_with_distance = list(queryset)
                for bike in bikes_with_distance:
                    bike.distance = haversine(user_lon, user_lat, bike.longitude, bike.latitude)
                bikes_with_distance.sort(key=lambda b: b.distance)
                serializer = self.get_serializer(bikes_with_distance, many=True)
                return Response(serializer.data)
            except (ValueError, TypeError):
                return Response({"error": "Invalid location data."}, status=status.HTTP_400_BAD_REQUEST)
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'], url_path='reserve')
    @db_transaction.atomic
    def reserve(self, request, pk=None):
        bike, user = self.get_object(), request.user
        
        if user.wallet.balance <= 0:
            return Response({'error': 'Insufficient funds. Please top up your wallet to make a reservation.'}, status.HTTP_400_BAD_REQUEST)


        if bike.status != 'AVAILABLE': return Response({'error': 'Bike not available.'}, status.HTTP_400_BAD_REQUEST)
        if Ride.objects.filter(user=user, end_time__isnull=True).exists() or Bike.objects.filter(reserved_by=user).exists():
            return Response({'error': 'Active ride or reservation exists.'}, status.HTTP_400_BAD_REQUEST)
        try:
            duration_minutes = int(request.data.get('duration', 5))
            if not (5 <= duration_minutes <= 30): raise ValueError()
        except (ValueError, TypeError):
            return Response({'error': 'Invalid duration.'}, status.HTTP_400_BAD_REQUEST)
        bike.status, bike.reserved_by, bike.reservation_expires_at = 'RESERVED', user, timezone.now() + timedelta(minutes=duration_minutes)
        bike.save()
        return Response(BikeSerializer(bike).data)

    @action(detail=True, methods=['post'], url_path='cancel-reservation')
    @db_transaction.atomic
    def cancel_reservation(self, request, pk=None):
        bike, user = self.get_object(), request.user
        if bike.status != 'RESERVED' or bike.reserved_by != user: return Response({'error': 'Reservation not found.'}, status.HTTP_400_BAD_REQUEST)
        cancellation_fee = Decimal('5.00')
        wallet = get_object_or_404(Wallet, user=user)
        wallet.balance -= cancellation_fee
        wallet.save()
        Transaction.objects.create(wallet=wallet, amount=-cancellation_fee, transaction_type='CANCELLATION_FEE', description=f"Fee for bike {bike.id}")
        bike.status, bike.reserved_by, bike.reservation_expires_at = 'AVAILABLE', None, None
        bike.save()
        return Response({'message': 'Reservation cancelled.', 'fee_charged': str(cancellation_fee)})

class ParkingZoneViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = ParkingZone.objects.filter(is_active=True)
    serializer_class = ParkingZoneSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name']

class RideViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['post'], url_path='start-ride')
    @db_transaction.atomic
    def start_ride(self, request):
        qr_code, user = request.data.get('qr_code'), request.user
        bike = get_object_or_404(Bike, qr_code=qr_code)
        
        if user.wallet.balance <= 0:
            return Response({'error': 'Insufficient funds. Please top up your wallet to start a ride.'}, status.HTTP_400_BAD_REQUEST)


        if Ride.objects.filter(user=user, end_time__isnull=True).exists(): return Response({'error': 'Active ride exists.'}, status.HTTP_400_BAD_REQUEST)
        if bike.status == 'RESERVED':
            if bike.reserved_by != user: return Response({'error': 'Bike reserved by another user.'}, status.HTTP_400_BAD_REQUEST)
            if bike.reservation_expires_at and timezone.now() > bike.reservation_expires_at:
                bike.status, bike.reserved_by, bike.reservation_expires_at = 'AVAILABLE', None, None
                bike.save()
                return Response({'error': 'Your reservation expired.'}, status.HTTP_400_BAD_REQUEST)
        elif bike.status != 'AVAILABLE': return Response({'error': 'Bike not available.'}, status.HTTP_400_BAD_REQUEST)
        ride = Ride.objects.create(user=user, bike=bike, start_latitude=bike.latitude, start_longitude=bike.longitude)
        bike.status, bike.reserved_by, bike.reservation_expires_at = 'IN_USE', None, None
        bike.save()
        return Response(RideSerializer(ride).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['post'], url_path='end-ride')
    @db_transaction.atomic
    def end_ride(self, request, pk=None):
        ride = get_object_or_404(Ride, id=pk, user=request.user, end_time__isnull=True)
        final_lat, final_lon = request.data.get('latitude'), request.data.get('longitude')
        distance = request.data.get('distance')
        calories = request.data.get('calories')
        if not final_lat or not final_lon: return Response({'error': 'Final location required.'}, status=status.HTTP_400_BAD_REQUEST)
        if not any(haversine(final_lon, final_lat, z.longitude, z.latitude) <= z.radius for z in ParkingZone.objects.filter(is_active=True)):
            return Response({'error': 'Must park in a designated zone.'}, status=status.HTTP_400_BAD_REQUEST)
        ride.end_latitude, ride.end_longitude, ride.end_time = final_lat, final_lon, timezone.now()
        
        if distance is not None:
            ride.distance_meters = Decimal(distance)
        if calories is not None:
            ride.calories_burned = int(float(calories))

        active_pass = UserPass.objects.filter(user=request.user, expires_at__gt=timezone.now()).first()
        if not active_pass:
            base_cost = ceil(Decimal((ride.end_time - ride.start_time).total_seconds() / 60) * Decimal('1.50'))
            discount = base_cost * (request.user.corporate_account.discount_percentage / Decimal('100')) if request.user.corporate_account else 0
            ride.cost = base_cost - discount
            wallet = get_object_or_404(Wallet, user=request.user)
            wallet.balance -= ride.cost
            wallet.save()
            Transaction.objects.create(wallet=wallet, amount=-ride.cost, transaction_type='RIDE_PAYMENT', description=f"Ride {ride.id}")
        else: ride.cost = Decimal('0.00')
        # --- User statistics update (more efficient save) ---
        ride_minutes = int((ride.end_time - ride.start_time).total_seconds() // 60)
        user = request.user
        if ride.distance_meters:
            user.total_distance_meters += ride.distance_meters
        if ride.calories_burned:
            user.total_calories_burned += ride.calories_burned
        user.total_duration_minutes += ride_minutes
        user.save(update_fields=[
            'total_distance_meters',
            'total_calories_burned',
            'total_duration_minutes',
        ])
        ride.save()
        
        bike = ride.bike
        bike.status, bike.latitude, bike.longitude = 'AVAILABLE', final_lat, final_lon
        bike.save()
        
        return Response(RideSerializer(ride).data, status=status.HTTP_200_OK)

class BikeIoTUpdateView(generics.UpdateAPIView):
    queryset = Bike.objects.all()
    serializer_class = BikeSerializer
    permission_classes = [permissions.AllowAny]

class WalletViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]
    def list(self, request):
        wallet = get_object_or_404(Wallet, user=request.user)
        return Response(WalletSerializer(wallet).data)
    @action(detail=False, methods=['post'], url_path='top-up')
    def top_up(self, request):
        amount_str, payment_method = request.data.get('amount'), request.data.get('payment_method', 'Unknown')
        if not amount_str: return Response({'error': 'Amount required.'}, status=status.HTTP_400_BAD_REQUEST)
        try: amount_decimal = Decimal(amount_str)
        except InvalidOperation: return Response({'error': 'Invalid amount.'}, status=status.HTTP_400_BAD_REQUEST)
        wallet = get_object_or_404(Wallet, user=request.user)
        wallet.balance += amount_decimal
        wallet.save()
        Transaction.objects.create(wallet=wallet, amount=amount_decimal, transaction_type='TOPUP', description=f"Top up via {payment_method}")
        return Response({'message': 'Wallet topped up.', 'new_balance': wallet.balance})
    @action(detail=False, methods=['post'], url_path='purchase-pass')
    @db_transaction.atomic
    def purchase_pass(self, request):
        pass_id = request.data.get('pass_id')
        pass_obj = get_object_or_404(Pass, id=pass_id, is_active=True)
        wallet = get_object_or_404(Wallet, user=request.user)
        if wallet.balance < pass_obj.price: return Response({'error': 'Insufficient balance.'}, status=status.HTTP_400_BAD_REQUEST)
        wallet.balance -= pass_obj.price
        wallet.save()
        Transaction.objects.create(wallet=wallet, amount=-pass_obj.price, transaction_type='PASS_PURCHASE', description=f"Purchased {pass_obj.name}")
        user_pass = UserPass.objects.create(user=request.user, pass_type=pass_obj, expires_at=timezone.now() + timedelta(days=pass_obj.duration_days))
        return Response(UserPassSerializer(user_pass).data, status=status.HTTP_201_CREATED)

class PassViewSet(viewsets.ReadOnlyModelViewSet):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = PassSerializer
    queryset = Pass.objects.filter(is_active=True)

class BikeReportViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = BikeReportSerializer
    def get_queryset(self): return BikeReport.objects.filter(user=self.request.user)
    @db_transaction.atomic
    def perform_create(self, serializer):
        bike = get_object_or_404(Bike, id=self.request.data.get('bike_id'))
        serializer.save(user=self.request.user, bike=bike)
        bike.status = 'BROKEN'
        bike.save()

class SupportTicketViewSet(viewsets.ModelViewSet):
    serializer_class = SupportTicketSerializer
    permission_classes = [permissions.IsAuthenticated]
    def get_queryset(self): return SupportTicket.objects.filter(user=self.request.user).order_by('-created_at')
    def perform_create(self, serializer): serializer.save(user=self.request.user)



@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_user_statistics(request):
    user = request.user
    stats = {
        'duration': f"{user.total_duration_minutes} mins",
        'distance': f"{user.total_distance_meters:.0f} m",
        'calories': f"{user.total_calories_burned} cal",
        'carbon': f"{user.total_distance_meters * Decimal('0.01'):.2f} oz"
    }
    return Response(stats)


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_referral_code(request):
    return Response({'invitation_code': request.user.referral_code})


# --- REVISED: UserProfileView to handle updates ---
class UserProfileView(generics.RetrieveUpdateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get_serializer_class(self):
        if self.request.method == 'PATCH':
            return UserProfileUpdateSerializer
        return UserSerializer

    def get_object(self):
        return self.request.user


# --- Admin Panel API Views ---

class IsAdminOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow admins to edit objects.
    """
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user and request.user.is_staff

class AdminUserViewSet(viewsets.ModelViewSet):
    """Admin view for managing users."""
    queryset = User.objects.all().order_by('-date_joined')
    serializer_class = AdminUserSerializer
    permission_classes = [permissions.IsAdminUser]
    filter_backends = [filters.SearchFilter]
    search_fields = ['email', 'username', 'phone_number']

    @action(detail=True, methods=['post'], url_path='toggle-active')
    def toggle_active(self, request, pk=None):
        user = self.get_object()
        user.is_active = not user.is_active
        user.save()
        return Response({'status': 'success', 'is_active': user.is_active})

class AdminCorporateAccountViewSet(viewsets.ModelViewSet):
    """Admin view for managing corporate accounts."""
    queryset = CorporateAccount.objects.all().order_by('company_name')
    serializer_class = CorporateAccountSerializer
    permission_classes = [permissions.IsAdminUser]
    filter_backends = [filters.SearchFilter]
    search_fields = ['company_name', 'email_domain']

class AdminBikeViewSet(viewsets.ModelViewSet):
    """Admin view for managing all bikes."""
    queryset = Bike.objects.all().order_by('-last_reported_at')
    serializer_class = AdminBikeSerializer
    permission_classes = [permissions.IsAdminUser]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['qr_code']
    ordering_fields = ['last_reported_at', 'battery_level']

class AdminRideViewSet(viewsets.ReadOnlyModelViewSet):
    """Admin view for viewing all rides."""
    queryset = Ride.objects.all().select_related('user', 'bike').order_by('-start_time')
    serializer_class = AdminRideSerializer
    permission_classes = [permissions.IsAdminUser]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['user__email', 'bike__qr_code']
    ordering_fields = ['start_time', 'end_time', 'cost']

class AdminSupportTicketViewSet(viewsets.ModelViewSet):
    """Admin view for managing all support tickets."""
    queryset = SupportTicket.objects.all().select_related('user').order_by('-created_at')
    serializer_class = AdminSupportTicketSerializer
    permission_classes = [permissions.IsAdminUser]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['user__email', 'subject']
    ordering_fields = ['created_at', 'status']

class AdminParkingZoneViewSet(viewsets.ModelViewSet):
    """Admin view for managing parking zones with full CRUD."""
    queryset = ParkingZone.objects.all().order_by('name')
    serializer_class = ParkingZoneSerializer
    permission_classes = [permissions.IsAdminUser]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name']


class AdminDashboardStatsView(generics.GenericAPIView):
    """
    Provides aggregated statistics for the admin dashboard.
    """
    permission_classes = [permissions.IsAdminUser]

    def get(self, request, *args, **kwargs):
        total_users = User.objects.count()
        total_bikes = Bike.objects.count()
        active_rides = Ride.objects.filter(end_time__isnull=True).count()
        total_revenue = Ride.objects.aggregate(total=models.Sum('cost'))['total'] or 0

        # Rides per day for the last 7 days
        seven_days_ago = timezone.now() - timedelta(days=7)
        rides_per_day = Ride.objects.filter(start_time__gte=seven_days_ago) \
            .extra(select={'day': 'date(start_time)'}) \
            .values('day') \
            .annotate(count=models.Count('id')) \
            .order_by('day')

        # Bike status distribution
        bike_status_distribution = Bike.objects.values('status') \
            .annotate(count=models.Count('status')) \
            .order_by('status')

        return Response({
            'total_users': total_users,
            'total_bikes': total_bikes,
            'active_rides': active_rides,
            'total_revenue': f"{total_revenue:.2f}",
            'rides_per_day': list(rides_per_day),
            'bike_status_distribution': list(bike_status_distribution),
        })
