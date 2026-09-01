import 'package:latlong2/latlong.dart';

class MapService {
  // F-8 Islamabad approximate boundaries
  // These are approximate coordinates - you can adjust later

  static const List<LatLng> f8MarkazBoundary = [
    LatLng(33.70853, 73.03971),
    LatLng(33.71024, 73.04277),
    LatLng(33.714454, 73.039620),
    LatLng(33.712775, 73.036509),

  ];

  static const List<LatLng> f8_1Boundary = [
    LatLng(33.70938, 73.02999),
    LatLng(33.71276, 73.03651),
    LatLng(33.70478, 73.04250),
    LatLng(33.70131, 73.03608),

  ];

  static const List<LatLng> f8_2Boundary = [
    LatLng(33.71355, 73.02709),
    LatLng(33.71836, 73.03672),
    LatLng(33.71443, 73.03956),
    LatLng(33.70938, 73.02999),

  ];

  static const List<LatLng> f8_3Boundary = [
    LatLng(33.71836, 73.03672),
    LatLng(33.71021, 73.04277),
    LatLng(33.71396, 73.05011),
    LatLng(33.72206, 73.04398),
  ];

  static const List<LatLng> f8_4Boundary = [
    LatLng(33.71396, 73.05011),
    LatLng(33.71010, 73.05292),
    LatLng(33.70473, 73.04256),
    LatLng(33.70853, 73.03971),
  ];

  // Center points for each section (for map centering)
  static const LatLng f8MarkazCenter = LatLng(33.71136, 73.03981);
  static const LatLng f8_1Center = LatLng(33.707947, 73.035800);
  static const LatLng f8_2Center = LatLng(33.71413, 73.03372);
  static const LatLng f8_3Center = LatLng(33.71642, 73.04312);
  static const LatLng f8_4Center = LatLng(33.70979, 73.04578);

  // Get boundary by sector name
  static List<LatLng>? getBoundary(String sector) {
    switch (sector) {
      case 'F-8_Markaz':
        return f8MarkazBoundary;
      case 'F-8_1':
        return f8_1Boundary;
      case 'F-8_2':
        return f8_2Boundary;
      case 'F-8_3':
        return f8_3Boundary;
      case 'F-8_4':
        return f8_4Boundary;
      default:
        return null;
    }
  }

  // Get center by sector name
  static LatLng? getCenter(String sector) {
    switch (sector) {
      case 'F-8_Markaz':
        return f8MarkazCenter;
      case 'F-8_1':
        return f8_1Center;
      case 'F-8_2':
        return f8_2Center;
      case 'F-8_3':
        return f8_3Center;
      case 'F-8_4':
        return f8_4Center;
      default:
        return null;
    }
  }

  // Get readable name
  static String getReadableName(String sector) {
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
}

