from django.db import models
from django.contrib.gis.db import models as gis_models
from users.models import User

class VendorCategory(models.Model):
    """Categories for vendors (food, crafts, etc.)"""
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    
    def __str__(self):
        return self.name

class Vendor(models.Model):
    """Vendor profile model"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='vendor_profile', null=True, blank=True)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    category = models.ForeignKey(VendorCategory, on_delete=models.SET_NULL, null=True, related_name='vendors')
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.name