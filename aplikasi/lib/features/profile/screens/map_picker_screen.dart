import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(-6.2000, 106.8166); // Default to Jakarta
  String _currentAddress = "Geser peta untuk memilih lokasi";
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      if (mounted) {
        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentCenter, 15.0);
        _updateAddress();
      }
    } catch (e) {
      debugPrint("Gagal mengambil lokasi: $e");
    }
  }

  Future<void> _updateAddress() async {
    setState(() => _isGeocoding = true);
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${_currentCenter.latitude}&lon=${_currentCenter.longitude}&zoom=18&addressdetails=1';
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'NeoPay_POS_App',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          final List<String> parts = [];
          if (address['road'] != null) parts.add(address['road']);
          if (address['suburb'] != null) parts.add(address['suburb']);
          if (address['city_district'] != null) parts.add(address['city_district']);
          if (address['city'] != null) parts.add(address['city']);
          
          setState(() {
            _currentAddress = parts.isNotEmpty ? parts.join(', ') : (data['display_name'] ?? "Lokasi tidak bernama");
          });
        } else {
          setState(() => _currentAddress = data['display_name'] ?? "Alamat tidak ditemukan");
        }
      } else {
        setState(() => _currentAddress = "Gagal memuat alamat (Server Error)");
      }
    } catch (e) {
      setState(() => _currentAddress = "Gagal memuat alamat: $e");
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111727),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  setState(() => _currentCenter = pos.center);
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _updateAddress();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.neopay.app',
              ),
            ],
          ),
          
          // Center Marker (Fixed)
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35.h),
              child: Icon(Icons.location_on, color: Colors.redAccent, size: 40.r),
            ),
          ),

          // Header
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: const BoxDecoration(color: Color(0xFF111727), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111727),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Text('Pilih Lokasi Toko', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Info & Button
          Positioned(
            bottom: 30.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: const Color(0xFF111727),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFFBEF364)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _currentAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                        ),
                      ),
                      if (_isGeocoding) 
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFBEF364))),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, _currentAddress),
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(color: const Color(0xFFBEF364), borderRadius: BorderRadius.circular(14.r)),
                      child: const Center(
                        child: Text('KONFIRMASI LOKASI', style: TextStyle(color: Color(0xFF111727), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
