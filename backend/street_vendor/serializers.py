from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Vendor, Customer, Product, Order, OrderItem, Review

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name')
        read_only_fields = ('id',)

class VendorSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    business_name = serializers.CharField(required=True)
    phone_number = serializers.CharField(required=True)
    address = serializers.CharField(required=True)

    class Meta:
        model = Vendor
        fields = ('id', 'user', 'business_name', 'phone_number', 'address', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

class CustomerSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    phone_number = serializers.CharField(required=True)
    address = serializers.CharField(required=True)

    class Meta:
        model = Customer
        fields = ('id', 'user', 'phone_number', 'address', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

class ProductSerializer(serializers.ModelSerializer):
    vendor = VendorSerializer(read_only=True)
    vendor_id = serializers.PrimaryKeyRelatedField(
        queryset=Vendor.objects.all(),
        write_only=True,
        source='vendor'
    )

    class Meta:
        model = Product
        fields = ('id', 'vendor', 'vendor_id', 'name', 'description', 'price', 'image', 
                 'is_available', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

class OrderItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    product_id = serializers.PrimaryKeyRelatedField(
        queryset=Product.objects.all(),
        write_only=True,
        source='product'
    )

    class Meta:
        model = OrderItem
        fields = ('id', 'product', 'product_id', 'quantity', 'price', 'created_at')
        read_only_fields = ('id', 'created_at')

class OrderSerializer(serializers.ModelSerializer):
    customer = CustomerSerializer(read_only=True)
    vendor = VendorSerializer(read_only=True)
    items = OrderItemSerializer(many=True, read_only=True)
    customer_id = serializers.PrimaryKeyRelatedField(
        queryset=Customer.objects.all(),
        write_only=True,
        source='customer'
    )
    vendor_id = serializers.PrimaryKeyRelatedField(
        queryset=Vendor.objects.all(),
        write_only=True,
        source='vendor'
    )

    class Meta:
        model = Order
        fields = ('id', 'customer', 'customer_id', 'vendor', 'vendor_id', 'status',
                 'total_amount', 'items', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

class ReviewSerializer(serializers.ModelSerializer):
    customer = CustomerSerializer(read_only=True)
    vendor = VendorSerializer(read_only=True)
    customer_id = serializers.PrimaryKeyRelatedField(
        queryset=Customer.objects.all(),
        write_only=True,
        source='customer'
    )
    vendor_id = serializers.PrimaryKeyRelatedField(
        queryset=Vendor.objects.all(),
        write_only=True,
        source='vendor'
    )

    class Meta:
        model = Review
        fields = ('id', 'customer', 'customer_id', 'vendor', 'vendor_id', 'rating',
                 'comment', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at') 