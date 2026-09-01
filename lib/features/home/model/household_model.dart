import 'package:flutter/material.dart';

enum HouseholdStatus { done, refused, absent, pending }

extension HouseholdStatusX on HouseholdStatus {
  String get label {
    switch (this) {
      case HouseholdStatus.done:
        return 'Done';
      case HouseholdStatus.refused:
        return 'Refused';
      case HouseholdStatus.absent:
        return 'Absent';
      case HouseholdStatus.pending:
        return 'Pending';
    }
  }

  Color get color {
    switch (this) {
      case HouseholdStatus.done:
        return const Color(0xFF34A853);
      case HouseholdStatus.refused:
        return const Color(0xFFE53935);
      case HouseholdStatus.absent:
        return const Color(0xFFF5A623);
      case HouseholdStatus.pending:
        return const Color(0xFF9E9E9E);
    }
  }
}

enum ChildVaccinationStatus { eligible, vaccinated }

extension ChildVaccinationStatusX on ChildVaccinationStatus {
  String get label {
    switch (this) {
      case ChildVaccinationStatus.eligible:
        return 'Eligible';
      case ChildVaccinationStatus.vaccinated:
        return 'Vaccinated';
    }
  }

  Color get color {
    switch (this) {
      case ChildVaccinationStatus.eligible:
        return const Color(0xFFE8833A);
      case ChildVaccinationStatus.vaccinated:
        return const Color(0xFF34A853);
    }
  }
}

class ChildInfo {
  final String name;
  final String age;
  final ChildVaccinationStatus status;

  const ChildInfo({
    required this.name,
    required this.age,
    required this.status,
  });
}

class Household {
  final String id; // e.g. HH-0247
  final String familyName;
  final String laneBlock; // short address shown on the list tile
  final HouseholdStatus status;
  final bool visitedToday;

  // Detail-screen fields
  final String houseAddress;
  final String ucTehsil;
  final String guardianCnic;
  final String headName;
  final List<ChildInfo> children;

  const Household({
    required this.id,
    required this.familyName,
    required this.laneBlock,
    required this.status,
    required this.houseAddress,
    required this.ucTehsil,
    required this.guardianCnic,
    required this.headName,
    required this.children,
    this.visitedToday = false,
  });

  int get eligibleCount =>
      children.where((c) => c.status == ChildVaccinationStatus.eligible).length;

  int get vaccinatedCount => children
      .where((c) => c.status == ChildVaccinationStatus.vaccinated)
      .length;
}