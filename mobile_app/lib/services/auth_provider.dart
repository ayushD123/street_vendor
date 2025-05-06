// lib/services/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String baseUrl = 'http://10.0.2.2:8000/api'; // For Android emulator
  // final String baseUrl = 'http://localhost:8000/api'; // For iOS simulator
  
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _username;
  String? _userType;
  int? _userId;
  String? _lastError;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get userType => _userType;
  int? get userId => _userId;
  String? get lastError => _lastError;
  
  AuthProvider() {
    _loadStoredAuth();
  }
  
  Future<void> _loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
    }
    notifyListeners();
  }
  
  Future<void> _saveAuth(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', json.encode(user.toJson()));
    _token = token;
    _currentUser = user;
    notifyListeners();
  }
  
  // Check if user is already logged in on app startup
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (_token != null) {
        try {
          _username = await _apiService.read(key: 'username');
          _userType = await _apiService.read(key: 'user_type');
          final userIdStr = await _apiService.read(key: 'user_id');
          _userId = userIdStr != null ? int.parse(userIdStr) : null;
          
          _isLoggedIn = true;
          
          // Try to fetch current user profile
          try {
            _currentUser = await _apiService.getUserProfile();
          } catch (e) {
            // If token is expired or invalid, logout
            if (e.toString().contains('401')) {
              await logout();
            }
          }
        } catch (e) {
          // If we can't read from storage or get user profile, logout
          await logout();
        }
      } else {
        _isLoggedIn = false;
      }
    } catch (e) {
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Register a new user
  Future<bool> register(String username, String email, String password, String userType) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    
    try {
      await _apiService.register(username, email, password, userType);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      print('Registration error: $_lastError');
      notifyListeners();
      return false;
    }
  }
  
  // Login user
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data['user']);
        await _saveAuth(data['access'], user);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _apiService.logout();
    _isLoggedIn = false;
    _username = null;
    _userType = null;
    _userId = null;
    _currentUser = null;
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Check if user is a contributor
  bool isContributor() {
    return _userType == 'contributor' || _userType == 'vendor';
  }
  
  // Check if user is a vendor
  bool isVendor() {
    return _userType == 'vendor';
  }
}