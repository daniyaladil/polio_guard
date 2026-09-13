import 'package:latlong2/latlong.dart';
import '../../../core/services/houses_data.dart';
import '../model/household_model.dart';

/// Bridges the shared HouseData (used by admin) into worker-side Household model.
class WorkerMapData {
  /// Returns all HouseData rows for one sector.
  static List<HouseData> housesInSector(String sector) {
    return DummyHouseData.getAllHouses()
        .where((h) => h.sector == sector)
        .toList();
  }

  /// Converts a HouseData row into a Household (worker view).
  /// Children are static dummy (2 kids) for now.
  static Household toHousehold(HouseData h) {
    return Household(
      id: h.id,
      familyName: h.familyName,
      laneBlock: h.address,
      status: _mapStatus(h.status),
      visitedToday: false,
      houseAddress: h.address,
      ucTehsil: 'UC-32, Tehsil Islamabad',
      guardianCnic: '17301-0000000-0',
      headName: h.familyName,
      children: const [
        ChildInfo(
          name: 'Child A',
          age: '2 years',
          status: ChildVaccinationStatus.eligible,
        ),
        ChildInfo(
          name: 'Child B',
          age: '4 years',
          status: ChildVaccinationStatus.eligible,
        ),
      ],
    );
  }

  /// Returns Household list for a sector (converted).
  static List<Household> householdsInSector(String sector) {
    return housesInSector(sector).map(toHousehold).toList();
  }

  /// Status counts for a sector.
  static Map<HouseholdStatus, int> statusCounts(String sector) {
    final houses = housesInSector(sector);
    int done = 0, refused = 0, absent = 0, pending = 0;
    for (final h in houses) {
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
      HouseholdStatus.done: done,
      HouseholdStatus.refused: refused,
      HouseholdStatus.absent: absent,
      HouseholdStatus.pending: pending,
    };
  }

  /// Readable sector name.
  static String readableSector(String sector) {
    switch (sector) {
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
        return sector;
    }
  }

  static HouseholdStatus _mapStatus(String s) {
    switch (s) {
      case 'vaccinated':
        return HouseholdStatus.done;
      case 'refused':
        return HouseholdStatus.refused;
      case 'absent':
        return HouseholdStatus.absent;
      default:
        return HouseholdStatus.pending;
    }
  }
}