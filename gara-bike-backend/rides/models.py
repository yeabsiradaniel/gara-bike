# rides/models.py

from django.db import models
from django.contrib.auth.models import AbstractUser
from django.conf import settings
from django.utils import timezone
import uuid
import random
import string

def generate_referral_code():
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))

class CorporateAccount(models.Model):
    company_name = models.CharField(max_length=255, unique=True)
    email_domain = models.CharField(max_length=255, unique=True, help_text="The company's email domain (e.g., gara.com)")
    discount_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=0.00, help_text="e.g., 15.00 for 15% discount")
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.company_name} ({self.discount_percentage}%)"

class User(AbstractUser):
    email = models.EmailField(unique=True, verbose_name='email address')
    phone_number = models.CharField(max_length=20, unique=True, blank=False, null=False)
    nid = models.CharField(max_length=50, unique=True, blank=False, null=False, help_text="National ID Number")
    is_verified = models.BooleanField(default=False)
    referral_code = models.CharField(max_length=8, default=generate_referral_code, unique=True)
    corporate_account = models.ForeignKey(CorporateAccount, on_delete=models.SET_NULL, null=True, blank=True, related_name='employees')

    # Lifetime stats
    total_distance_meters = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    total_calories_burned = models.PositiveIntegerField(default=0)
    total_duration_minutes = models.PositiveIntegerField(default=0)
    
    # --- NEW: FAVORITE LOCATION FIELDS ---
    home_address_name = models.CharField(max_length=255, null=True, blank=True)
    home_address_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    home_address_lon = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    
    work_address_name = models.CharField(max_length=255, null=True, blank=True)
    work_address_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    work_address_lon = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    # --- END NEW ---

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username', 'phone_number', 'nid']

    def __str__(self):
        return self.email

class ParkingZone(models.Model):
    name = models.CharField(max_length=100)
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    radius = models.PositiveIntegerField(help_text="Radius of the parking zone in meters.")
    is_active = models.BooleanField(default=True)
    def __str__(self): return self.name

class Bike(models.Model):
    class BikeStatus(models.TextChoices):
        AVAILABLE = 'AVAILABLE', 'Available'
        IN_USE = 'IN_USE', 'In Use'
        RESERVED = 'RESERVED', 'Reserved'
        MAINTENANCE = 'MAINTENANCE', 'Maintenance'
        BROKEN = 'BROKEN', 'Broken'
    qr_code = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    status = models.CharField(max_length=20, choices=BikeStatus.choices, default=BikeStatus.AVAILABLE)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    battery_level = models.PositiveIntegerField(default=100)
    last_reported_at = models.DateTimeField(auto_now=True)
    reserved_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='reserved_bike')
    reservation_expires_at = models.DateTimeField(null=True, blank=True)

    def __str__(self): return f"Bike {self.id} ({self.status})"

class Ride(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='rides')
    bike = models.ForeignKey(Bike, on_delete=models.CASCADE, related_name='rides')
    start_latitude = models.DecimalField(max_digits=9, decimal_places=6)
    start_longitude = models.DecimalField(max_digits=9, decimal_places=6)
    end_latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    end_longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    distance_meters = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    calories_burned = models.PositiveIntegerField(null=True, blank=True)

    def __str__(self): return f"Ride for {self.user.email}"

class Wallet(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='wallet')
    balance = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    def __str__(self): return f"{self.user.email}'s Wallet"

class Transaction(models.Model):
    class TransactionType(models.TextChoices):
        TOPUP = 'TOPUP', 'Top Up'
        RIDE_PAYMENT = 'RIDE_PAYMENT', 'Ride Payment'
        PASS_PURCHASE = 'PASS_PURCHASE', 'Pass Purchase'
        CANCELLATION_FEE = 'CANCELLATION_FEE', 'Cancellation Fee'
    wallet = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='transactions')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_type = models.CharField(max_length=20, choices=TransactionType.choices)
    timestamp = models.DateTimeField(auto_now_add=True)
    description = models.CharField(max_length=255, blank=True)
    def __str__(self): return f"{self.transaction_type}"

class SupportTicket(models.Model):
    class TicketStatus(models.TextChoices): OPEN, IN_PROGRESS, CLOSED = 'OPEN', 'IN_PROGRESS', 'CLOSED'
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='support_tickets')
    subject = models.CharField(max_length=255)
    message = models.TextField()
    status = models.CharField(max_length=20, choices=TicketStatus.choices, default=TicketStatus.OPEN)
    created_at = models.DateTimeField(auto_now_add=True)
    def __str__(self): return f"Ticket from {self.user.email}"

class Pass(models.Model):
    name = models.CharField(max_length=100, unique=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    duration_days = models.PositiveIntegerField()
    is_active = models.BooleanField(default=True)
    def __str__(self): return f"{self.name}"

class UserPass(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='passes')
    pass_type = models.ForeignKey(Pass, on_delete=models.PROTECT)
    purchased_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    def is_active(self): return self.expires_at > timezone.now()
    def __str__(self): return f"Pass for {self.user.email}"

class BikeReport(models.Model):
    REPORT_TYPES = (('BROKEN_BIKE', 'Broken Bike'), ('UNAUTHORIZED_LOCK', 'Unauthorized Lock'), ('OTHER', 'Other'))
    bike = models.ForeignKey(Bike, on_delete=models.CASCADE, related_name='reports')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    report_type = models.CharField(max_length=50, choices=REPORT_TYPES)
    comments = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    is_resolved = models.BooleanField(default=False)
    def __str__(self): return f"Report for {self.bike.id}"