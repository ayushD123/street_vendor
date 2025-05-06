// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/vendor.dart';
import '../models/vendor_category.dart';
import '../models/vendor_location.dart';
import 'dart:async';
import 'dart:io';

class ApiService {
  // Base URL for the API - change to your actual server address
  static const String baseUrl = 'http://192.168.30.231:8000/api/';  // Your computer's IP address
  // static const String baseUrl = 'http://10.0.2.2:8000/api/';  // 10.0.2.2 for Android emulator
  // static const String baseUrl = 'http://localhost:8000/api/';  // localhost for Chrome
  final storage = FlutterSecureStorage();
  
  // Add timeout settings
  static const Duration timeout = Duration(seconds: 30);
  
  // Get the auth token from storage
  Future<String?> _getToken() async {
    return await storage.read(key: 'auth_token');
  }
  
  // Add auth token to headers
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _getToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    
    return headers;
  }
  
  // Register a new user
  Future<Map<String, dynamic>> register(String username, String email, String password, String userType) async {
    try {
      print('Attempting to register user: $username');
      print('Using API URL: ${baseUrl}register/');
      
      final uri = Uri.parse('${baseUrl}register/');
      print('Parsed URI: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'user_type': userType,
        }),
      ).timeout(timeout);
      
      print('Registration response status: ${response.statusCode}');
      print('Registration response headers: ${response.headers}');
      print('Registration response body: ${response.body}');
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Registration failed';
        
        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          } else {
            errorMessage = errorData.entries
                .where((entry) => entry.value is List)
                .map((entry) => '${entry.key}: ${(entry.value as List).join(", ")}')
                .join('\n');
          }
        }
        
        throw Exception('Registration failed: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Registration error: $e');
      if (e is TimeoutException) {
        print('Connection timed out. Please check your internet connection and try again.');
        throw Exception('Connection timed out. Please check your internet connection and try again.');
      } else if (e is SocketException) {
        print('Socket Exception: ${e.message}');
        throw Exception('Could not connect to the server. Please check your internet connection and try again.');
      } else if (e is Exception) {
        print('Other Exception: ${e.toString()}');
        rethrow;
      }
      print('Unknown error: $e');
      throw Exception('Network error during registration: $e');
    }
  }
  
  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('Attempting to login user: $username');
      print('Using API URL: ${baseUrl}login/');
      
      final uri = Uri.parse('${baseUrl}login/');
      print('Parsed URI: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(timeout);
      
      print('Login response status: ${response.statusCode}');
      print('Login response headers: ${response.headers}');
      print('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Login failed';
        
        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          } else {
            errorMessage = errorData.entries
                .where((entry) => entry.value is List)
                .map((entry) => '${entry.key}: ${(entry.value as List).join(", ")}')
                .join('\n');
          }
        }
        
        throw Exception('Login failed: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Login error: $e');
      if (e is TimeoutException) {
        print('Connection timed out. Please check your internet connection and try again.');
        throw Exception('Connection timed out. Please check your internet connection and try again.');
      } else if (e is SocketException) {
        print('Socket Exception: ${e.message}');
        throw Exception('Could not connect to the server. Please check your internet connection and try again.');
      } else if (e is Exception) {
        print('Other Exception: ${e.toString()}');
        rethrow;
      }
      print('Unknown error: $e');
      throw Exception('Network error during login: $e');
    }
  }
  
  // Logout
  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'username');
    await storage.delete(key: 'user_type');
    await storage.delete(key: 'user_id');
  }
  
  // Get the current user's profile
  Future<User> getUserProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}profile/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
  
  // Get all vendor categories
  Future<List<VendorCategory>> getCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}categories/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => VendorCategory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
  
  // Get all vendors
  Future<List<Vendor>> getVendors() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}vendors/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Vendor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vendors');
    }
  }
  
  // Get a specific vendor
  Future<Vendor> getVendor(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}vendors/$id/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return Vendor.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load vendor');
    }
  }
  
  // Create a new vendor
  Future<Vendor> createVendor(Vendor vendor) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${baseUrl}vendors/'),
      headers: headers,
      body: jsonEncode(vendor.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Vendor.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create vendor: ${response.body}');
    }
  }
  
  // Get all vendor locations
  Future<List<VendorLocation>> getLocations() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}locations/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> features = data['features'];
      return features.map((json) => VendorLocation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load locations');
    }
  }
  
  // Get nearby vendor locations
  Future<List<VendorLocation>> getNearbyLocations(double lat, double lng, double distance) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}locations/nearby/?lat=$lat&lng=$lng&distance=$distance'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> features = data['features'];
      return features.map((json) => VendorLocation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load nearby locations');
    }
  }
  
  // Create a new vendor location
  Future<VendorLocation> createLocation(VendorLocation location) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${baseUrl}locations/'),
      headers: headers,
      body: jsonEncode(location.toJson()),
    );
    
    if (response.statusCode == 201) {
      return VendorLocation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create location: ${response.body}');
    }
  }
  
  // Verify a vendor location
  Future<void> verifyLocation(int locationId, bool isVerified) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${baseUrl}verifications/'),
      headers: headers,
      body: jsonEncode({
        'location': locationId,
        'is_verified': isVerified,
      }),
    );
    
    if (response.statusCode != 201) {
      throw Exception('Failed to verify location: ${response.body}');
    }
  }

  Future<List<VendorLocation>> getNearbyVendors(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}vendors/nearby/?lat=$latitude&lng=$longitude&radius=$radius'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VendorLocation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load nearby vendors');
      }
    } catch (e) {
      throw Exception('Error fetching nearby vendors: $e');
    }
  }

  Future<void> addVendorLocation(Map<String, dynamic> locationData) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}vendors/locations/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(locationData),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add vendor location');
      }
    } catch (e) {
      throw Exception('Error adding vendor location: $e');
    }
  }

  Future<void> verifyVendorLocation(int locationId, bool isVerified) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}vendors/locations/$locationId/verify/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'is_verified': isVerified}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to verify vendor location');
      }
    } catch (e) {
      throw Exception('Error verifying vendor location: $e');
    }
  }

  // Get a value from secure storage
  Future<String?> read({required String key}) async {
    try {
      return await storage.read(key: key);
    } catch (e) {
      return null;
    }
  }
}