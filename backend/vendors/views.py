from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, permissions, filters
from .models import Vendor, VendorCategory
from .serializers import VendorSerializer, VendorCategorySerializer
from rest_framework.decorators import action
from rest_framework.response import Response

class IsOwnerOrReadOnly(permissions.BasePermission):
    """Custom permission to only allow owners of an object to edit it."""
    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write permissions are only allowed to the owner
        return obj.user == request.user

class VendorCategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = VendorCategory.objects.all()
    serializer_class = VendorCategorySerializer
    permission_classes = [permissions.AllowAny]

class VendorViewSet(viewsets.ModelViewSet):
    queryset = Vendor.objects.all()
    serializer_class = VendorSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'description', 'category__name']
    
    def perform_create(self, serializer):
        # Associate the new vendor with the current user if they're a vendor type
        if self.request.user.user_type == 'vendor':
            serializer.save(user=self.request.user)
        else:
            serializer.save()