import 'dart:async';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/map_service.dart';
import '../../../core/services/visits_service.dart';

class HouseRow {
  final String id;
  final String sector;
  final String address;
  final String familyName;
  final double lat;
  final double lng;
  final String status; // 'pending' | 'vaccinated' | 'absent' | 'refused'

  HouseRow({
    required this.id,
    required this.sector,
    required this.address,
    required this.familyName,
    required this.lat,
    required this.lng,
    required this.status,
  });

  factory HouseRow.fromMap(Map<String, dynamic> m) => HouseRow(
    id: (m['houseId'] ?? m['id'] ?? '').toString(),
    sector: (m['sector'] ?? '').toString(),
    address: (m['address'] ?? '').toString(),
    familyName: (m['familyName'] ?? 'Family').toString(),
    lat: (m['lat'] as num?)?.toDouble() ?? 0,
    lng: (m['lng'] as num?)?.toDouble() ?? 0,
    status: (m['status'] ?? 'pending').toString(),
  );

  LatLng get coordinates => LatLng(lat, lng);
}

class WorkerController extends GetxController {
  final FirebaseService _firebase = Get.find<FirebaseService>();

  var workerName = ''.obs;
  var assignedSector = ''.obs;
  var isLoading = true.obs;

  // Live houses from Firestore
  var sectorHouses = <HouseRow>[].obs;

  // Map helpers
  List<LatLng>? boundary;
  LatLng? center;

  StreamSubscription? _housesSub;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _housesSub?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;

    final user = _firebase.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    final data = await _firebase.getUserData(user.uid);
    if (data == null) {
      isLoading.value = false;
      return;
    }

    workerName.value = (data['name'] ?? 'Worker').toString();
    assignedSector.value = (data['assignedSector'] ?? '').toString();

    if (assignedSector.value.isEmpty) {
      isLoading.value = false;
      return;
    }

    boundary = MapService.getBoundary(assignedSector.value);
    center = MapService.getCenter(assignedSector.value);

    // Subscribe to live Firestore houses for this sector
    _housesSub?.cancel();
    _housesSub = VisitsService.sectorHousesStream(assignedSector.value)
        .listen((docs) {
      sectorHouses.value =
          docs.map((m) => HouseRow.fromMap(m)).toList();
      // Sort by address so the list is stable
      sectorHouses.sort((a, b) => a.address.compareTo(b.address));
      isLoading.value = false;
    }, onError: (e) {
      print('❌ houses stream error: $e');
      isLoading.value = false;
    });
  }

  Color colorFor(String status) {
    switch (status) {
      case 'vaccinated':
        return const Color(0xFF34A853);
      case 'refused':
        return const Color(0xFFE53935);
      case 'absent':
        return const Color(0xFFF5A623);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String labelFor(String status) {
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

  Map<String, int> get counts {
    int done = 0, refused = 0, absent = 0, pending = 0;
    for (final h in sectorHouses) {
      switch (h.status) {
        case 'vaccinated':
          done++;
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
    return {
      'done': done,
      'refused': refused,
      'absent': absent,
      'pending': pending,
    };
  }

  String readableSector() {
    switch (assignedSector.value) {
      case 'F-8_Markaz':
        return 'F-8 Markaz';
      case 'F-8_1':
        return 'F-8/1';
      case 'F-8_2':
        return 'F-8/2';
      case 'F-8_3':
        return 'F-8/3';
      case 'F-8_4':
        return 'F-8/4';
      default:
        return assignedSector.value;
    }
  }
}