import '../model/household_model.dart';

/// Hardcoded dummy data for the Home screen and Household Detail screen.
/// Replace with real data from your API/database later.
class DummyHouseholds {
  static const wardName = 'Ward 7 - Sector B';
  static const totalAssigned = 42;
  static const doneCount = 18;
  static const refusedCount = 5;
  static const absentCount = 7;
  static const pendingCount = 12;

  static final List<Household> list = [
    const Household(
      id: 'HH-0247',
      familyName: 'Rashid Family',
      laneBlock: 'Lane 4, Block C',
      status: HouseholdStatus.pending,
      visitedToday: false,
      houseAddress: 'House #22, Street 4, Lane 4, Block C',
      ucTehsil: 'UC-32, Tehsil Peshawar City',
      guardianCnic: '17301-5512340-1',
      headName: 'Abdul Rashid',
      children: [
        ChildInfo(
          name: 'Zainab Rashid',
          age: '1 year 6 months',
          status: ChildVaccinationStatus.eligible,
        ),
        ChildInfo(
          name: 'Usman Rashid',
          age: '4 years 2 months',
          status: ChildVaccinationStatus.eligible,
        ),
      ],
    ),
    const Household(
      id: 'HH-0251',
      familyName: 'Bibi Khatoon',
      laneBlock: 'Lane 6, Block A',
      status: HouseholdStatus.absent,
      visitedToday: false,
      houseAddress: 'House #9, Street 6, Lane 6, Block A',
      ucTehsil: 'UC-32, Tehsil Peshawar City',
      guardianCnic: '17301-6673321-5',
      headName: 'Bibi Khatoon',
      children: [
        ChildInfo(
          name: 'Sara Khatoon',
          age: '2 years 1 month',
          status: ChildVaccinationStatus.eligible,
        ),
      ],
    ),
    const Household(
      id: 'HH-0263',
      familyName: 'Marwan Siddiq',
      laneBlock: 'Lane 2, Block D',
      status: HouseholdStatus.refused,
      visitedToday: false,
      houseAddress: 'House #17, Street 2, Lane 2, Block D',
      ucTehsil: 'UC-32, Tehsil Peshawar City',
      guardianCnic: '17301-4498761-3',
      headName: 'Marwan Siddiq',
      children: [
        ChildInfo(
          name: 'Ibrahim Siddiq',
          age: '3 years',
          status: ChildVaccinationStatus.eligible,
        ),
        ChildInfo(
          name: 'Hoorain Siddiq',
          age: '9 months',
          status: ChildVaccinationStatus.eligible,
        ),
      ],
    ),
    const Household(
      id: 'HH-0270',
      familyName: 'Tariq Family',
      laneBlock: 'Street 7, Mohalla Rasheedabad',
      status: HouseholdStatus.done,
      visitedToday: true,
      houseAddress: 'House #14, Street 7, Mohalla Rasheedabad',
      ucTehsil: 'UC-32, Tehsil Peshawar City',
      guardianCnic: '17301-8456723-9',
      headName: 'Muhammad Tariq Khan',
      children: [
        ChildInfo(
          name: 'Ayesha Tariq',
          age: '2 years 4 months',
          status: ChildVaccinationStatus.eligible,
        ),
        ChildInfo(
          name: 'Hassan Tariq',
          age: '11 months',
          status: ChildVaccinationStatus.eligible,
        ),
        ChildInfo(
          name: 'Bilal Tariq',
          age: '3 years 8 months',
          status: ChildVaccinationStatus.vaccinated,
        ),
        ChildInfo(
          name: 'Fatima Tariq',
          age: '6 months',
          status: ChildVaccinationStatus.eligible,
        ),
      ],
    ),
  ];
}