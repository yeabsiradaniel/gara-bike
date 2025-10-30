# rides/admin_urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    AdminUserViewSet,
    AdminCorporateAccountViewSet,
    AdminBikeViewSet,
    AdminRideViewSet,
    AdminSupportTicketViewSet,
    AdminParkingZoneViewSet,
    AdminDashboardStatsView,
)

router = DefaultRouter()
router.register(r'users', AdminUserViewSet, basename='admin-user')
router.register(r'corporate-accounts', AdminCorporateAccountViewSet, basename='admin-corporate-account')
router.register(r'bikes', AdminBikeViewSet, basename='admin-bike')
router.register(r'rides', AdminRideViewSet, basename='admin-ride')
router.register(r'support-tickets', AdminSupportTicketViewSet, basename='admin-support-ticket')
router.register(r'parking-zones', AdminParkingZoneViewSet, basename='admin-parking-zone')

urlpatterns = [
    path('dashboard-stats/', AdminDashboardStatsView.as_view(), name='admin-dashboard-stats'),
    path('', include(router.urls)),
]
