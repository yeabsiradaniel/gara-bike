
# rides/serializers.py

from rest_framework import serializers
from django.db import transaction
from django.contrib.auth.password_validation import validate_password

from .models import (
    User, ParkingZone, Bike, Ride, Wallet, Transaction, SupportTicket,
    Pass, UserPass, BikeReport, CorporateAccount
)


# --- NEW: User Profile Update Serializer ---
class UserProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'username', 'phone_number',
            'home_address_name', 'home_address_lat', 'home_address_lon',
            'work_address_name', 'work_address_lat', 'work_address_lon'
        ]
        # Make fields not required for partial updates (PATCH)
        extra_kwargs = {
            'username': {'required': False},
            'phone_number': {'required': False},
        }

# User serializer for basic user info
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'phone_number', 'nid', 'referral_code',
            'total_distance_meters', 'total_calories_burned', 'total_duration_minutes',
            # --- NEWLY ADDED FIELDS ---
            'home_address_name', 'home_address_lat', 'home_address_lon',
            'work_address_name', 'work_address_lat', 'work_address_lon'
        ]

# Registration serializer with password validation and corporate account linking
class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ('username', 'password', 'password2', 'email', 'phone_number', 'nid')

    def validate(self, attrs):
        # Ensure both passwords match
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})
        return attrs

    def create(self, validated_data):
        # Create user and link to corporate account if email domain matches
        with transaction.atomic():
            user_email = validated_data['email'].lower()
            email_domain = user_email.split('@')[-1]
            corporate_account = CorporateAccount.objects.filter(email_domain=email_domain, is_active=True).first()
            user = User.objects.create(
                username=validated_data['username'],
                email=user_email,
                phone_number=validated_data['phone_number'],
                nid=validated_data['nid'],
                corporate_account=corporate_account
            )
            user.set_password(validated_data['password'])
            user.is_active = False  # Require verification before activation
            user.save()
            Wallet.objects.create(user=user)
        return user

# Parking zone serializer
class ParkingZoneSerializer(serializers.ModelSerializer):
    class Meta:
        model = ParkingZone
        fields = ['id', 'name', 'latitude', 'longitude', 'radius', 'is_active']

# Bike serializer with extra read-only fields for reservation info
class BikeSerializer(serializers.ModelSerializer):
    distance = serializers.FloatField(read_only=True, required=False)
    reserved_by = UserSerializer(read_only=True)
    reservation_expires_at = serializers.DateTimeField(read_only=True)

    class Meta:
        model = Bike
        fields = [
            'id', 'qr_code', 'status', 'latitude', 'longitude',
            'battery_level', 'distance', 'reserved_by', 'reservation_expires_at'
        ]

# Ride serializer with nested user and bike info
class RideSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    bike = BikeSerializer(read_only=True)

    class Meta:
        model = Ride
        fields = [
            'id', 'user', 'bike', 'start_latitude', 'start_longitude',
            'end_latitude', 'end_longitude', 'start_time', 'end_time', 'cost',
            'distance_meters', 'calories_burned'
        ]

# Transaction serializer
class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = ['id', 'amount', 'transaction_type', 'timestamp', 'description']

# Wallet serializer with nested user and ordered transactions
class WalletSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    transactions = serializers.SerializerMethodField()

    class Meta:
        model = Wallet
        fields = ['id', 'user', 'balance', 'transactions']

    def get_transactions(self, obj):
        # Return transactions ordered by most recent first
        transactions = obj.transactions.all().order_by('-timestamp')
        return TransactionSerializer(transactions, many=True).data

# Support ticket serializer
class SupportTicketSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = SupportTicket
        fields = ['id', 'user', 'subject', 'message', 'status', 'created_at']
        read_only_fields = ['status', 'user']

# Pass serializer
class PassSerializer(serializers.ModelSerializer):
    class Meta:
        model = Pass
        fields = ['id', 'name', 'price', 'duration_days', 'is_active']

# UserPass serializer with nested pass info
class UserPassSerializer(serializers.ModelSerializer):
    pass_type = PassSerializer(read_only=True)

    class Meta:
        model = UserPass
        fields = ['id', 'pass_type', 'purchased_at', 'expires_at']

# Bike report serializer with nested user and bike info
class BikeReportSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    bike = BikeSerializer(read_only=True)

    class Meta:
        model = BikeReport
        fields = ['id', 'bike', 'user', 'report_type', 'comments', 'created_at']


# --- Admin Panel Serializers ---

class CorporateAccountSerializer(serializers.ModelSerializer):
    """Serializer for the CorporateAccount model (for admin)."""
    class Meta:
        model = CorporateAccount
        fields = ['id', 'company_name', 'email_domain', 'discount_percentage', 'is_active']

class AdminUserSerializer(serializers.ModelSerializer):
    """Serializer for the User model for the admin panel."""
    corporate_account = CorporateAccountSerializer(read_only=True)
    corporate_account_id = serializers.PrimaryKeyRelatedField(
        queryset=CorporateAccount.objects.all(), source='corporate_account', write_only=True, required=False, allow_null=True
    )

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'phone_number', 'is_staff', 'is_active',
            'is_verified', 'corporate_account', 'corporate_account_id', 'date_joined'
        ]
        read_only_fields = ['date_joined']

class AdminBikeSerializer(serializers.ModelSerializer):
    """Serializer for the Bike model for the admin panel."""
    class Meta:
        model = Bike
        fields = [
            'id', 'qr_code', 'status', 'latitude', 'longitude',
            'battery_level', 'last_reported_at'
        ]

class AdminRideSerializer(serializers.ModelSerializer):
    """Serializer for the Ride model for the admin panel."""
    user = UserSerializer(read_only=True)
    bike = BikeSerializer(read_only=True)

    class Meta:
        model = Ride
        fields = [
            'id', 'user', 'bike', 'start_time', 'end_time', 'cost',
            'distance_meters', 'start_latitude', 'start_longitude',
            'end_latitude', 'end_longitude'
        ]

class AdminSupportTicketSerializer(serializers.ModelSerializer):
    """Serializer for the SupportTicket model for the admin panel."""
    user = UserSerializer(read_only=True)

    class Meta:
        model = SupportTicket
        fields = ['id', 'user', 'subject', 'message', 'status', 'created_at']
        # Admin can change the status, so it's not read-only here.
