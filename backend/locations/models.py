from django.contrib.gis.db import models
from vendors.models import Vendor
from users.models import User
from django.utils import timezone
from datetime import timedelta

class VendorLocation(models.Model):
    """Model for vendor locations"""
    vendor = models.ForeignKey(Vendor, on_delete=models.CASCADE, related_name='locations')
    point = models.PointField()  # GeoDjango point field for coordinates
    address = models.CharField(max_length=255, blank=True, null=True)
    reported_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='reported_locations')
    confidence_score = models.FloatField(default=0.5)  # Confidence in location accuracy
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Optional schedule fields
    scheduled_start = models.TimeField(null=True, blank=True)
    scheduled_end = models.TimeField(null=True, blank=True)
    days_of_week = models.CharField(max_length=100, blank=True)  # Comma-separated list of days (e.g., "Mon,Tue,Wed")
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.vendor.name} at {self.address}"
    
    @property
    def is_current(self):
        """Check if this location is still considered current based on time"""
        time_threshold = timezone.now() - timedelta(hours=24)
        return self.updated_at >= time_threshold

class LocationVerification(models.Model):
    """Model for tracking location verifications by contributors"""
    location = models.ForeignKey(VendorLocation, on_delete=models.CASCADE, related_name='verifications')
    verified_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='verified_locations')
    is_verified = models.BooleanField(default=True)  # False for "not found"
    verification_time = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ('location', 'verified_by')