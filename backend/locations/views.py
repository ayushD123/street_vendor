from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, permissions, filters
from django.contrib.gis.measure import D
from django.contrib.gis.geos import Point
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import VendorLocation, LocationVerification
from .serializers import VendorLocationSerializer, LocationVerificationSerializer
from vendors.views import IsOwnerOrReadOnly

class VendorLocationViewSet(viewsets.ModelViewSet):
    queryset = VendorLocation.objects.filter(is_active=True)
    serializer_class = VendorLocationSerializer
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            permission_classes = [permissions.IsAuthenticated]
        else:
            permission_classes = [permissions.AllowAny]
        return [permission() for permission in permission_classes]

    def perform_create(self, serializer):
        # Associate the current user as the reporter
        serializer.save(reported_by=self.request.user)
    
    @action(detail=False, methods=['get'])
    def nearby(self, request):
        """Find vendors near a specified location"""
        lat = request.query_params.get('lat', None)
        lng = request.query_params.get('lng', None)
        distance = request.query_params.get('distance', 5)  # in kilometers
        
        if lat is None or lng is None:
            return Response({"error": "Latitude and longitude parameters are required"}, status=400)
        
        try:
            lat = float(lat)
            lng = float(lng)
            distance = float(distance)
        except ValueError:
            return Response({"error": "Invalid coordinates or distance"}, status=400)
        
        user_location = Point(lng, lat, srid=4326)
        
        # Find locations within the specified distance
        nearby_locations = VendorLocation.objects.filter(
            is_active=True,
            point__distance_lte=(user_location, D(km=distance))
        )
        
        serializer = self.get_serializer(nearby_locations, many=True)
        return Response(serializer.data)

class LocationVerificationViewSet(viewsets.ModelViewSet):
    queryset = LocationVerification.objects.all()
    serializer_class = LocationVerificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(verified_by=self.request.user)