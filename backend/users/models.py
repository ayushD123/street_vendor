from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    """Extended user model with additional fields"""
    USER_TYPE_CHOICES = [
        ('regular', 'Regular User'),
        ('contributor', 'Contributor'),
        ('vendor', 'Vendor'),
    ]
    
    user_type = models.CharField(max_length=20, choices=USER_TYPE_CHOICES, default='regular')
    trust_score = models.FloatField(default=0.5)  # Trust score from 0.0 to 1.0
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    
    def __str__(self):
        return self.username