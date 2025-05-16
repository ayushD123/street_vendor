# vendor_tracker_backend/vendor_tracker_backend/urls.py
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from users.views import RegisterView, CustomAuthToken, UserProfileView
from vendors.views import VendorViewSet, VendorCategoryViewSet
from locations.views import VendorLocationViewSet, LocationVerificationViewSet

# Create a router for our viewsets
router = DefaultRouter()
router.register(r'vendors', VendorViewSet)
router.register(r'categories', VendorCategoryViewSet)
router.register(r'locations', VendorLocationViewSet)
router.register(r'verifications', LocationVerificationViewSet)

# Admin site configuration
admin.site.site_header = "Street Vendor Admin"
admin.site.site_title = "Street Vendor Admin Portal"
admin.site.index_title = "Welcome to Street Vendor Admin Portal"

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('api/register/', RegisterView.as_view(), name='register'),
    path('api/login/', CustomAuthToken.as_view(), name='login'),
    path('api/profile/', UserProfileView.as_view(), name='profile'),
    path('api-auth/', include('rest_framework.urls')),
]