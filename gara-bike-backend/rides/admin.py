# rides/admin.py

from django.contrib import admin
from .models import (
    User, ParkingZone, Bike, Ride, Wallet, Transaction, SupportTicket,
    Pass, UserPass, BikeReport, CorporateAccount
)

@admin.register(CorporateAccount)
class CorporateAccountAdmin(admin.ModelAdmin):
    list_display = ('company_name', 'email_domain', 'discount_percentage', 'is_active')
    search_fields = ('company_name', 'email_domain')
    list_filter = ('is_active',)

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('email', 'username', 'phone_number', 'corporate_account', 'is_verified', 'is_staff')
    search_fields = ('email', 'username', 'phone_number')
    list_filter = ('corporate_account', 'is_staff', 'is_superuser', 'is_active')

@admin.register(ParkingZone)
class ParkingZoneAdmin(admin.ModelAdmin):
    list_display = ('name', 'radius', 'is_active')
    search_fields = ('name',)

@admin.register(Bike)
class BikeAdmin(admin.ModelAdmin):
    # Add reservation fields to the display
    list_display = ('id', 'qr_code', 'status', 'battery_level', 'reserved_by', 'reservation_expires_at')
    list_filter = ('status',)
    search_fields = ('id', 'qr_code', 'reserved_by__email')
    readonly_fields = ('last_reported_at',)

@admin.register(Ride)
class RideAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'bike', 'start_time', 'end_time', 'cost')
    search_fields = ('user__email', 'bike__id')
    readonly_fields = ('start_time', 'end_time')
    
@admin.register(Wallet)
class WalletAdmin(admin.ModelAdmin):
    list_display = ('user', 'balance')
    search_fields = ('user__email',)

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('wallet', 'transaction_type', 'amount', 'timestamp')
    list_filter = ('transaction_type',)
    search_fields = ('wallet__user__email',)

@admin.register(SupportTicket)
class SupportTicketAdmin(admin.ModelAdmin):
    list_display = ('user', 'subject', 'status', 'created_at')
    list_filter = ('status',)
    search_fields = ('user__email', 'subject')

@admin.register(Pass)
class PassAdmin(admin.ModelAdmin):
    list_display = ('name', 'price', 'duration_days', 'is_active')
    list_filter = ('is_active',)

@admin.register(UserPass)
class UserPassAdmin(admin.ModelAdmin):
    list_display = ('user', 'pass_type', 'purchased_at', 'expires_at')
    search_fields = ('user__email',)

@admin.register(BikeReport)
class BikeReportAdmin(admin.ModelAdmin):
    list_display = ('bike', 'user', 'report_type', 'created_at', 'is_resolved')
    list_filter = ('report_type', 'is_resolved')
    search_fields = ('bike__id', 'user__email')
