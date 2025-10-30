# rides/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RegisterView, verify_otp, get_user_statistics, get_referral_code,
    BikeViewSet, RideViewSet, WalletViewSet, SupportTicketViewSet,
    PassViewSet, BikeReportViewSet, UserProfileView, BikeIoTUpdateView,
    ParkingZoneViewSet, get_active_reservation, get_active_ride
)

# App-facing router
router = DefaultRouter()
router.register(r'bikes', BikeViewSet, basename='bike')
router.register(r'rides', RideViewSet, basename='ride')
router.register(r'wallet', WalletViewSet, basename='wallet')
router.register(r'support-tickets', SupportTicketViewSet, basename='support-ticket')
router.register(r'passes', PassViewSet, basename='pass')
router.register(r'bike-reports', BikeReportViewSet, basename='bike-report')
# The app should only be able to read parking zones
router.register(r'parking-zones', ParkingZoneViewSet, basename='parking-zone')


urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('verify-otp/', verify_otp, name='verify-otp'),
    path('users/me/', UserProfileView.as_view(), name='user-profile'),
    path('iot/bike/<int:pk>/update/', BikeIoTUpdateView.as_view(), name='iot-bike-update'),
    path('statistics/', get_user_statistics, name='user-statistics'),
    path('invite-friends/', get_referral_code, name='invite-friends'),
    path('reservations/active/', get_active_reservation, name='active-reservation'),
    path('rides/active/', get_active_ride, name='active-ride'),
    path('', include(router.urls)),
]
