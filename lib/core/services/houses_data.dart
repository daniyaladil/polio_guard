import 'dart:ui';

import 'package:latlong2/latlong.dart';

class HouseData {
  final String id;
  final String sector;
  final String address;
  final LatLng coordinates;
  final String status; // 'vaccinated', 'refused', 'absent', 'pending'
  final String workerId;
  final String familyName;

  HouseData({
    required this.id,
    required this.sector,
    required this.address,
    required this.coordinates,
    this.status = 'pending',
    required this.workerId,
    required this.familyName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sector': sector,
    'address': address,
    'latitude': coordinates.latitude,
    'longitude': coordinates.longitude,
    'status': status,
    'workerId': workerId,
    'familyName': familyName,
  };

  factory HouseData.fromJson(Map<String, dynamic> json) => HouseData(
    id: json['id'],
    sector: json['sector'],
    address: json['address'],
    coordinates: LatLng(json['latitude'], json['longitude']),
    status: json['status'] ?? 'pending',
    workerId: json['workerId'],
    familyName: json['familyName'],
  );

  Color get statusColor {
    switch (status) {
      case 'vaccinated':
        return const Color(0xFF34A853); // Green
      case 'refused':
        return const Color(0xFFEA4335); // Red
      case 'absent':
        return const Color(0xFFFBBC04); // Yellow
      default:
        return const Color(0xFF9E9E9E); // Grey for pending
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

// Dummy House Data Generator
class DummyHouseData {
  static List<HouseData> getAllHouses() {
    List<HouseData> houses = [];

    // F-8 Markaz Houses (15 houses)
    houses.addAll([
      HouseData(
        id: 'H001',
        sector: 'F-8_Markaz',
        address: 'House #1, Main Markaz Road',
        coordinates: const LatLng(33.7105, 73.0520),
        status: 'vaccinated',
        workerId: 'worker_1',
        familyName: 'Ahmed Family',
      ),
    ]);

    // F-8/1 Houses (12 houses)
    houses.addAll([
      HouseData(
        id: 'H101',
        sector: 'F-8_1',
        address: 'House #1, Street 1, F-8/1',
        coordinates: const LatLng(33.702301, 73.035709),
        status: 'vaccinated',
        workerId: 'worker_2',
        familyName: 'Khalid Family',
      ),
      HouseData(
        id: 'H102',
        sector: 'F-8_1',
        address: 'House #2, Street 1, F-8/1',
        coordinates: const LatLng(33.702118, 73.035838),
        status: 'pending',
        workerId: 'worker_2',
        familyName: 'Rashid Family',
      ),
      HouseData(
        id: 'H103',
        sector: 'F-8_1',
        address: 'House #3, Street 2, F-8/1',
        coordinates: const LatLng(33.701882, 73.036026),
        status: 'vaccinated',
        workerId: 'worker_2',
        familyName: 'Nawaz Family',
      ),
      HouseData(
        id: 'H104',
        sector: 'F-8_1',
        address: 'House #4, Street 2, F-8/1',
        coordinates: const LatLng(33.701703, 73.036128),
        status: 'refused',
        workerId: 'worker_2',
        familyName: 'Shah Family',
      ),
      HouseData(
        id: 'H105',
        sector: 'F-8_1',
        address: 'House #5, Street 3, F-8/1',
        coordinates: const LatLng(33.702287, 73.036085),
        status: 'vaccinated',
        workerId: 'worker_2',
        familyName: 'Zahid Family',
      ),
      HouseData(
        id: 'H106',
        sector: 'F-8_1',
        address: 'House #6, Street 3, F-8/1',
        coordinates: const LatLng(33.701998, 73.036286),
        status: 'absent',
        workerId: 'worker_2',
        familyName: 'Aslam Family',
      ),
      HouseData(
        id: 'H107',
        sector: 'F-8_1',
        address: 'House #7, Street 4, F-8/1',
        coordinates: const LatLng(33.702156, 73.036546),
        status: 'vaccinated',
        workerId: 'worker_2',
        familyName: 'Qureshi Family',
      ),

      //strreet 20

    ]);

    // F-8/2 Houses (10 houses)
    houses.addAll([
      HouseData(
        id: 'H201',
        sector: 'F-8_2',
        address: 'House #1, Street A, F-8/2',
        coordinates: const LatLng(33.7035, 73.0460),
        status: 'vaccinated',
        workerId: 'worker_3',
        familyName: 'Anwar Family',
      ),
    ]);

    // F-8/3 Houses (10 houses)
    houses.addAll([
      HouseData(
        id: 'H301',
        sector: 'F-8_3',
        address: 'House #1, Street X, F-8/3',
        coordinates: const LatLng(33.7005, 73.0430),
        status: 'vaccinated',
        workerId: 'worker_4',
        familyName: 'Tariq Family',
      ),

    ]);

    // F-8/4 Houses (10 houses)
    houses.addAll([
      HouseData(
        id: 'H401',
        sector: 'F-8_4',
        address: 'House #1, Street P, F-8/4',
        coordinates: const LatLng(33.6975, 73.0400),
        status: 'vaccinated',
        workerId: 'worker_5',
        familyName: 'Hashmi Family',
      ),
    ]);

    return houses;
  }

  // Get houses by sector
  static List<HouseData> getHousesBySector(String sector) {
    return getAllHouses().where((house) => house.sector == sector).toList();
  }

  // Get houses by worker ID
  static List<HouseData> getHousesByWorker(String workerId) {
    return getAllHouses().where((house) => house.workerId == workerId).toList();
  }

  // Get statistics by sector
  static Map<String, dynamic> getSectorStats(String sector) {
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

  // Get overall statistics
  static Map<String, dynamic> getOverallStats() {
    final allHouses = getAllHouses();
    final total = allHouses.length;
    final vaccinated = allHouses.where((h) => h.status == 'vaccinated').length;
    final refused = allHouses.where((h) => h.status == 'refused').length;
    final absent = allHouses.where((h) => h.status == 'absent').length;
    final pending = allHouses.where((h) => h.status == 'pending').length;

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