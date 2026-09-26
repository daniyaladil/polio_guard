import 'package:cloud_firestore/cloud_firestore.dart';

enum VisitType { vaccinated, absent, refused }

extension VisitTypeX on VisitType {
  String get value {
    switch (this) {
      case VisitType.vaccinated:
        return 'vaccinated';
      case VisitType.absent:
        return 'absent';
      case VisitType.refused:
        return 'refused';
    }
  }

  String get label {
    switch (this) {
      case VisitType.vaccinated:
        return 'Vaccinated';
      case VisitType.absent:
        return 'Absent';
      case VisitType.refused:
        return 'Refused';
    }
  }
}

class VisitedChild {
  final String name;
  final String age;
  const VisitedChild({required this.name, required this.age});

  Map<String, dynamic> toJson() => {'name': name, 'age': age};
  factory VisitedChild.fromJson(Map<String, dynamic> j) =>
      VisitedChild(name: j['name'] ?? '', age: j['age'] ?? '');
}

class Visit {
  final String id;          // Firestore doc id
  final String houseId;
  final String sector;
  final String workerId;
  final String workerName;
  final VisitType type;
  final String mediaUrl;    // Cloudinary secure_url
  final String mediaType;   // 'video' | 'image'
  final List<VisitedChild> children; // empty unless vaccinated
  final DateTime createdAt;

  Visit({
    required this.id,
    required this.houseId,
    required this.sector,
    required this.workerId,
    required this.workerName,
    required this.type,
    required this.mediaUrl,
    required this.mediaType,
    required this.children,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'houseId': houseId,
    'sector': sector,
    'workerId': workerId,
    'workerName': workerName,
    'type': type.value,
    'mediaUrl': mediaUrl,
    'mediaType': mediaType,
    'children': children.map((c) => c.toJson()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
  };
}