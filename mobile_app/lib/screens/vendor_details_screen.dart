import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/vendor_location.dart';
import '../services/api_service.dart';

class VendorDetailsScreen extends StatelessWidget {
  final VendorLocation location;
  final ApiService _apiService = ApiService();

  VendorDetailsScreen({required this.location});

  Future<void> _launchMaps() async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _verifyLocation(BuildContext context, bool isVerified) async {
    try {
      await _apiService.verifyVendorLocation(location.id, isVerified);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location ${isVerified ? 'verified' : 'reported'} successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.vendorName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(location.latitude, location.longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('vendor_location'),
                    position: LatLng(location.latitude, location.longitude),
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Address'),
                    subtitle: Text(location.address),
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text('Active Hours'),
                    subtitle: Text(
                      location.scheduledStart != null && location.scheduledEnd != null
                          ? '${location.scheduledStart!.hour}:00 - ${location.scheduledEnd!.hour}:00'
                          : 'Not specified',
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Available Days'),
                    subtitle: Text(location.daysOfWeek.join(', ')),
                  ),
                  ListTile(
                    leading: Icon(Icons.verified),
                    title: Text('Confidence Score'),
                    subtitle: Text('${(location.confidenceScore * 100).toStringAsFixed(1)}%'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _launchMaps,
                        icon: Icon(Icons.directions),
                        label: Text('Get Directions'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _verifyLocation(context, true),
                        icon: Icon(Icons.check),
                        label: Text('Verify'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _verifyLocation(context, false),
                        icon: Icon(Icons.report),
                        label: Text('Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 