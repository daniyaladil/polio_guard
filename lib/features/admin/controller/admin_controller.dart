import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/map_service.dart';
import '../../../core/services/visits_service.dart';
import '../../../features/home/model/visit_model.dart';
import '../screens/video_player_screen.dart';

class AdminController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Observables
  var isLoading = true.obs;
  var totalWorkers = 0.obs;
  var totalVaccinated = 0.obs;
  var totalPending = 0.obs;
  var totalRefused = 0.obs;
  var totalAbsent = 0.obs;
  var allHouses = <AdminHouseRow>[].obs;
  var currentZoom = 14.5.obs;

  // Map controller
  final MapController mapController = MapController();

  // Stream subscription
  StreamSubscription? _housesSub;

  // Sector colors
  final Map<String, Color> sectorColors = {
    'F-8_Markaz': const Color(0xFF1A73E8),
    'F-8_1': const Color(0xFF34A853),
    'F-8_2': const Color(0xFFFBBC04),
    'F-8_3': const Color(0xFF9C27B0),
    'F-8_4': const Color(0xFFEA4335),
  };

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
    _loadWorkersCount();
    _subscribeToAllHouses();
  }

  @override
  void onClose() {
    _housesSub?.cancel();
    mapController.dispose();
    super.onClose();
  }

  Future<void> _loadWorkersCount() async {
    try {
      final workersSnapshot = await _firebaseService.getWorkers().first;
      totalWorkers.value = workersSnapshot.docs.length;
    } catch (e) {
      print('Error loading workers: $e');
    }
  }

  void _subscribeToAllHouses() {
    _housesSub?.cancel();
    _housesSub = VisitsService.allHousesStream().listen((docs) {
      allHouses.value = docs.map((m) => AdminHouseRow.fromMap(m)).toList();
      _recalculateStats();
      isLoading.value = false;
    }, onError: (e) {
      print('❌ houses stream error: $e');
      isLoading.value = false;
    });
  }

  void _recalculateStats() {
    int vaccinated = 0, refused = 0, absent = 0, pending = 0;
    for (final h in allHouses) {
      switch (h.status) {
        case 'vaccinated':
          vaccinated++;
          break;
        case 'refused':
          refused++;
          break;
        case 'absent':
          absent++;
          break;
        default:
          pending++;
      }
    }
    totalVaccinated.value = vaccinated;
    totalRefused.value = refused;
    totalAbsent.value = absent;
    totalPending.value = pending;
  }

  List<AdminHouseRow> getHousesBySector(String sector) {
    return allHouses.where((house) => house.sector == sector).toList();
  }

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

  List<LatLng>? getSectorBoundary(String sector) {
    return MapService.getBoundary(sector);
  }

  LatLng? getSectorCenter(String sector) {
    return MapService.getCenter(sector);
  }

  void updateZoom(double zoom) {
    currentZoom.value = zoom;
  }

  double getMarkerSize(double zoom) {
    if (zoom < 12) return 8.0;
    if (zoom < 13) return 10.0;
    if (zoom < 14) return 14.0;
    if (zoom < 15) return 18.0;
    if (zoom < 16) return 22.0;
    if (zoom < 17) return 26.0;
    return 30.0;
  }

  double getFontSize(double markerSize) {
    if (markerSize < 12) return 4.0;
    if (markerSize < 16) return 6.0;
    if (markerSize < 20) return 8.0;
    if (markerSize < 24) return 10.0;
    return 12.0;
  }

  Future<void> logout() async {
    await _firebaseService.signOut();
    Get.offAllNamed('/login');
  }

  // ============================================
  // SHOW HOUSE DETAILS
  // ============================================
  Future<void> showHouseDetails(AdminHouseRow house, BuildContext context) async {
    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.white)),
      barrierDismissible: false,
    );

    // Fetch visit
    final visit = await _fetchLatestVisit(house.id);

    // Close loading
    Get.back();

    // Show bottom sheet
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        house.address,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
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
                const SizedBox(height: 20),

                // House Info
                _sectionTitle('House Information'),
                const SizedBox(height: 10),
                _detailRow(Icons.home, 'House ID', house.id),
                _detailRow(Icons.location_on, 'Sector',
                    house.sector.replaceAll('_', '/')),
                _detailRow(Icons.people, 'Family', house.familyName),
                _detailRow(Icons.my_location, 'Coordinates',
                    '${house.lat.toStringAsFixed(6)}, ${house.lng.toStringAsFixed(6)}'),

                // Visit info
                if (visit != null) ...[
                  const SizedBox(height: 20),
                  _sectionTitle('Visit Information'),
                  const SizedBox(height: 10),
                  _detailRow(Icons.person, 'Worker',
                      visit.workerName.isNotEmpty ? visit.workerName : 'Unknown'),
                  _detailRow(Icons.access_time, 'Visited At',
                      _formatDate(visit.createdAt)),
                  _detailRow(Icons.category, 'Visit Type', visit.type.label),

                  // Children
                  if (visit.children.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _sectionTitle('Vaccinated Children'),
                    const SizedBox(height: 10),
                    ...visit.children.map((child) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.child_care,
                              color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(child.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text('Age: ${child.age}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          Icon(Icons.check_circle,
                              color: Colors.green.shade700, size: 20),
                        ],
                      ),
                    )),
                  ],

                  // Video Proof
                  const SizedBox(height: 20),
                  _sectionTitle('Video Proof'),
                  const SizedBox(height: 10),
                  if (visit.mediaUrl.isNotEmpty && visit.mediaUrl.startsWith('http'))
                    _videoCard(visit.mediaUrl)
                  else
                    _noVideoCard(),
                ] else ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline,
                            size: 32, color: Colors.orange.shade700),
                        const SizedBox(height: 8),
                        Text('No visits recorded yet',
                            style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('This house is still pending',
                            style: TextStyle(
                                color: Colors.orange.shade600, fontSize: 11)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5276),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Close',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ============================================
  // FETCH LATEST VISIT — NO INDEX NEEDED
  // ============================================
  Future<Visit?> _fetchLatestVisit(String houseId) async {
    try {
      // ✅ No orderBy — avoids index requirement
      final snapshot = await FirebaseFirestore.instance
          .collection('visits')
          .where('houseId', isEqualTo: houseId)
          .get();

      if (snapshot.docs.isEmpty) return null;

      // Sort in Dart
      final docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final aTime = (a.data()['createdAt'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = (b.data()['createdAt'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      final doc = docs.first;
      final data = doc.data();

      return Visit(
        id: doc.id,
        houseId: data['houseId'] ?? '',
        sector: data['sector'] ?? '',
        workerId: data['workerId'] ?? '',
        workerName: data['workerName'] ?? '',
        type: _parseVisitType(data['type']),
        mediaUrl: data['mediaUrl'] ?? '',
        mediaType: data['mediaType'] ?? 'video',
        children: (data['children'] as List<dynamic>? ?? [])
            .map((c) => VisitedChild.fromJson(c as Map<String, dynamic>))
            .toList(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('Error fetching visit: $e');
      return null;
    }
  }

  VisitType _parseVisitType(String? type) {
    switch (type) {
      case 'vaccinated':
        return VisitType.vaccinated;
      case 'absent':
        return VisitType.absent;
      case 'refused':
        return VisitType.refused;
      default:
        return VisitType.vaccinated;
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A5276),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoCard(String videoUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.play_circle_fill,
                        size: 64, color: Colors.white.withOpacity(0.9)),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text('VIDEO PROOF',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => VideoPlayerScreen(videoUrl: videoUrl));
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                label: const Text(
                  'Play Video Proof',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noVideoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.videocam_off, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text('No Video Available',
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Video evidence not uploaded',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  // ============================================
  // LIVE STATS (from Firestore, real-time)
  // ============================================

  /// Overall stats from real Firestore data
  Map<String, int> get overallStats {
    int vaccinated = 0, refused = 0, absent = 0, pending = 0;
    for (final h in allHouses) {
      switch (h.status) {
        case 'vaccinated':
          vaccinated++;
          break;
        case 'refused':
          refused++;
          break;
        case 'absent':
          absent++;
          break;
        default:
          pending++;
      }
    }
    final total = allHouses.length;
    return {
      'total': total,
      'vaccinated': vaccinated,
      'refused': refused,
      'absent': absent,
      'pending': pending,
      'progress': total > 0 ? ((vaccinated / total) * 100).round() : 0,
    };
  }

  /// Sector-wise live stats
  Map<String, int> sectorStats(String sector) {
    final houses = allHouses.where((h) => h.sector == sector).toList();
    int vaccinated = 0, refused = 0, absent = 0, pending = 0;
    for (final h in houses) {
      switch (h.status) {
        case 'vaccinated':
          vaccinated++;
          break;
        case 'refused':
          refused++;
          break;
        case 'absent':
          absent++;
          break;
        default:
          pending++;
      }
    }
    final total = houses.length;
    return {
      'total': total,
      'vaccinated': vaccinated,
      'refused': refused,
      'absent': absent,
      'pending': pending,
      'progress': total > 0 ? ((vaccinated / total) * 100).round() : 0,
    };
  }
}

// ============================================
// ADMIN HOUSE ROW
// ============================================
class AdminHouseRow {
  final String id;
  final String sector;
  final String address;
  final String familyName;
  final double lat;
  final double lng;
  final String status;

  AdminHouseRow({
    required this.id,
    required this.sector,
    required this.address,
    required this.familyName,
    required this.lat,
    required this.lng,
    required this.status,
  });

  factory AdminHouseRow.fromMap(Map<String, dynamic> m) => AdminHouseRow(
    id: (m['houseId'] ?? m['id'] ?? '').toString(),
    sector: (m['sector'] ?? '').toString(),
    address: (m['address'] ?? '').toString(),
    familyName: (m['familyName'] ?? 'Family').toString(),
    lat: (m['lat'] as num?)?.toDouble() ?? 0,
    lng: (m['lng'] as num?)?.toDouble() ?? 0,
    status: (m['status'] ?? 'pending').toString(),
  );

  LatLng get coordinates => LatLng(lat, lng);

  Color get statusColor {
    switch (status) {
      case 'vaccinated':
        return const Color(0xFF34A853);
      case 'refused':
        return const Color(0xFFEA4335);
      case 'absent':
        return const Color(0xFFFBBC04);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String get statusLabel {
    switch (status) {
      case 'vaccinated':
        return '✅ Vaccinated';
      case 'refused':
        return '❌ Refused';
      case 'absent':
        return '⏳ Absent';
      default:
        return '⏳ Pending';
    }
  }
}