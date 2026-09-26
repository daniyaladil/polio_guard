import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/houses_data.dart';
import '../../features/home/controller/worker_controller.dart';
import '../../features/home/model/visit_model.dart';

class VisitsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Saves a visit and updates (or creates) the house doc.
  /// Overwrites previous status for the same house.
  static Future<bool> saveVisit({
    required HouseRow house,
    required String workerId,
    required String workerName,
    required VisitType type,
    required String mediaUrl,
    required String mediaType,
    List<VisitedChild> children = const [],
  }) async {
    try {
      final now = DateTime.now();

      await _db.collection('visits').add({
        'houseId': house.id,
        'sector': house.sector,
        'workerId': workerId,
        'workerName': workerName,
        'type': type.value,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'children': children.map((c) => c.toJson()).toList(),
        'createdAt': Timestamp.fromDate(now),
      });

      await _db.collection('houses').doc(house.id).set({
        'houseId': house.id,
        'sector': house.sector,
        'address': house.address,
        'familyName': house.familyName,
        'lat': house.lat,
        'lng': house.lng,
        'status': type.value,
        'lastVisitAt': Timestamp.fromDate(now),
        'lastVisitType': type.value,
        'lastVisitMediaUrl': mediaUrl,
        'lastWorkerId': workerId,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('❌ saveVisit error: $e');
      return false;
    }
  }

  /// Seeds the houses collection from DummyHouseData.
  /// ONLY creates missing docs. Never overwrites existing house data.
  /// Seeds the houses collection from DummyHouseData.
  /// ONLY creates missing docs. Never overwrites existing house data.
  static Future<void> seedHousesFromDummy() async {
    try {
      final houses = DummyHouseData.getAllHouses();
      print('🌱 Checking ${houses.length} houses…');

      // Fetch all existing house IDs in one go
      final existingSnap = await _db.collection('houses').get();
      final existingIds = existingSnap.docs.map((d) => d.id).toSet();

      // ✅ Generate UNIQUE doc IDs: "{originalId}_{sector}_{index}"
      // This prevents duplicates from overwriting each other
      final List<MapEntry<String, HouseData>> housesWithUniqueIds = [];
      final Map<String, int> idCounters = {};

      for (final h in houses) {
        final key = '${h.id}_${h.sector}';
        final count = idCounters[key] ?? 0;
        idCounters[key] = count + 1;

        // Unique doc ID like: H107_F-8_1_0, H107_F-8_1_1, H107_F-8_1_2
        final uniqueId = count == 0 ? '${h.id}_${h.sector}' : '${h.id}_${h.sector}_$count';
        housesWithUniqueIds.add(MapEntry(uniqueId, h));
      }

      // Only create docs that don't exist yet
      final missing = housesWithUniqueIds
          .where((e) => !existingIds.contains(e.key))
          .toList();

      if (missing.isEmpty) {
        print('✅ All houses already seeded');
        return;
      }

      print('🌱 Seeding ${missing.length} houses (unique IDs)…');

      // Batch write in chunks of 400 (Firestore limit = 500)
      const chunkSize = 400;
      for (var i = 0; i < missing.length; i += chunkSize) {
        final end = (i + chunkSize < missing.length)
            ? i + chunkSize
            : missing.length;
        final batch = _db.batch();
        for (var j = i; j < end; j++) {
          final uniqueId = missing[j].key;
          final h = missing[j].value;
          final ref = _db.collection('houses').doc(uniqueId);
          batch.set(ref, {
            'houseId': uniqueId,           // ✅ unique
            'originalId': h.id,            // keep original for reference
            'sector': h.sector,
            'address': h.address,
            'familyName': h.familyName,
            'lat': h.coordinates.latitude,
            'lng': h.coordinates.longitude,
            'status': 'pending',
            'seeded': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }

      print('✅ Seeded ${missing.length} new houses (existing preserved)');
    } catch (e) {
      print('❌ Seed error: $e');
    }
  }

  /// Stream of all houses in a sector (real-time, Firestore-backed).
  static Stream<List<Map<String, dynamic>>> sectorHousesStream(String sector) {
    return _db
        .collection('houses')
        .where('sector', isEqualTo: sector)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// Stream of ALL houses (for admin).
  static Stream<List<Map<String, dynamic>>> allHousesStream() {
    return _db
        .collection('houses')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

}