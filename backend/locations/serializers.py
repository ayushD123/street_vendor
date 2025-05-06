from rest_framework import serializers
from rest_framework_gis.serializers import GeoFeatureModelSerializer
from .models import VendorLocation, LocationVerification

class VendorLocationSerializer(GeoFeatureModelSerializer):
    vendor_name = serializers.ReadOnlyField(source='vendor.name')
    reported_by_username = serializers.ReadOnlyField(source='reported_by.username')
    
    class Meta:
        model = VendorLocation
        geo_field = 'point'
        fields = ['id', 'vendor', 'vendor_name', 'address', 'reported_by', 
                  'reported_by_username', 'confidence_score', 'is_active', 
                  'created_at', 'updated_at', 'scheduled_start', 'scheduled_end', 
                  'days_of_week', 'is_current']

class LocationVerificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = LocationVerification
        fields = ['id', 'location', 'verified_by', 'is_verified', 'verification_time']
        read_only_fields = ['verified_by', 'verification_time']