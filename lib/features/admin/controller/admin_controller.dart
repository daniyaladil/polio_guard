import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/houses_data.dart';
import '../../../core/services/map_service.dart';

class AdminController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Observables
  var isLoading = true.obs;
  var totalWorkers = 0.obs;
  var totalVaccinated = 0.obs;
  var totalPending = 0.obs;
  var totalRefused = 0.obs;
  var totalAbsent = 0.obs;
  var allHouses = <HouseData>[].obs;
  var currentZoom = 14.5.obs;

  // Map controller (not used for listener, just for map control)
  final MapController mapController = MapController();

  // Sector colors
  final Map<String, Color> sectorColors = {
    'F-8_Markaz': const Color(0xFF1A73E8),
    'F-8_1': const Color(0xFF34A853),
    'F-8_2': const Color(0xFFFBBC04),
    'F-8_3': const Color(0xFF9C27B0),
    'F-8_4': const Color(0xFFEA4335),
  };

  // Sector list
  final List<String> sectors = [
    'F-8_Markaz',
    'F-8_1',
    'F-8_2',
    'F-8_3',
    'F-8_4',
  ];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }

  // Update zoom level (called from UI)
  void updateZoom(double zoom) {
    currentZoom.value = zoom;
  }

  // Calculate marker size based on zoom level
  double getMarkerSize(double zoom) {
    if (zoom < 12) return 8.0;
    if (zoom < 13) return 10.0;
    if (zoom < 14) return 14.0;
    if (zoom < 15) return 18.0;
    if (zoom < 16) return 22.0;
    if (zoom < 17) return 26.0;
    return 30.0;
  }

  // Get font size based on marker size
  double getFontSize(double markerSize) {
    if (markerSize < 12) return 4.0;
    if (markerSize < 16) return 6.0;
    if (markerSize < 20) return 8.0;
    if (markerSize < 24) return 10.0;
    return 12.0;
  }

  // Load all data
  Future<void> loadData() async {
    isLoading.value = true;

    try {
      // Get workers count
      final workersSnapshot = await _firebaseService.getWorkers().first;
      totalWorkers.value = workersSnapshot.docs.length;

      // Load all houses
      allHouses.value = DummyHouseData.getAllHouses();

      // Calculate stats
      final stats = DummyHouseData.getOverallStats();
      totalVaccinated.value = stats['vaccinated'];
      totalPending.value = stats['pending'];
      totalRefused.value = stats['refused'];
      totalAbsent.value = stats['absent'];

      isLoading.value = false;
    } catch (e) {
      print('Error loading data: $e');
      isLoading.value = false;
    }
  }

  // Get houses by sector
  List<HouseData> getHousesBySector(String sector) {
    return allHouses.where((house) => house.sector == sector).toList();
  }

  // Get sector stats
  Map<String, dynamic> getSectorStats(String sector) {
    final houses = getHousesBySector(sector);
    final total = houses.length;
    final vaccinated = houses.where((h) => h.status == 'vaccinated').length;
    final refused = houses.where((h) => h.status == 'refused').length;
    final absent = houses.where((h) => h.status == 'absent').length;
    final pending = houses.where((h) => h.status == 'pending').length;

    return {
      'total': total,
      'vaccinated': vaccinated,
      'refused': refused,
      'absent': absent,
      'pending': pending,
      'progress': total > 0 ? ((vaccinated / total) * 100).round() : 0,
    };
  }

  // Get sector boundary
  List<LatLng>? getSectorBoundary(String sector) {
    return MapService.getBoundary(sector);
  }

  // Get sector center
  LatLng? getSectorCenter(String sector) {
    return MapService.getCenter(sector);
  }

  // Logout
  Future<void> logout() async {
    await _firebaseService.signOut();
    Get.offAllNamed('/login');
  }

  // Show house details in bottom sheet
  void showHouseDetails(HouseData house, BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'House Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: house.statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      house.statusLabel,
                      style: TextStyle(
                        color: house.statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildDetailRow(Icons.home, 'Address', house.address),
              _buildDetailRow(Icons.location_on, 'Sector', house.sector.replaceAll('_', '/')),
              _buildDetailRow(Icons.people, 'Family', house.familyName),
              _buildDetailRow(Icons.location_on_outlined, 'Coordinates',
                  '${house.coordinates.latitude.toStringAsFixed(6)}, ${house.coordinates.longitude.toStringAsFixed(6)}'),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5276),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}