from rest_framework import serializers
from .models import Vendor, VendorCategory

class VendorCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = VendorCategory
        fields = ['id', 'name', 'description']

class VendorSerializer(serializers.ModelSerializer):
    category_name = serializers.ReadOnlyField(source='category.name')
    
    class Meta:
        model = Vendor
        fields = ['id', 'name', 'description', 'category', 'category_name', 
                  'phone_number', 'is_verified', 'created_at']