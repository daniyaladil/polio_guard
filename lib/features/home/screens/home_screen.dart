import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:polio_guard/features/home/screens/voice_note_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../controller/worker_controller.dart';
import '../model/household_model.dart';
import '../widgets/house_bottomsheet.dart';
import '../widgets/household_tile.dart';
import 'all_households.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(WorkerController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'PolioGuard',
              style: AppTextStyles.bold
                  .copyWith(fontSize: 17.sp, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              radius: 15.r,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: Icon(Icons.person_outline,
                  color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.assignedSector.value.isEmpty) {
          return const Center(child: Text('No sector assigned'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MapCard(c: c),
              SizedBox(height: 16.h),
              _LegendCard(c: c),
              SizedBox(height: 20.h),
              _buildVoiceAwarenessButton(),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby Households',
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 15.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const AllHouseholdsScreen()),
                    child: Text(
                      'View All',
                      style: AppTextStyles.semiBold.copyWith(
                        fontSize: 12.5.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _HouseholdPreviewList(c: c),
              SizedBox(height: 82.h),
            ],
          ),
        );
      }),
    );
  }
  Widget _buildVoiceAwarenessButton() {
    return GestureDetector(
      onTap: () => Get.to(() => const VoiceNotesScreen()),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEA4335), Color(0xFFFF6B5C)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEA4335).withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.campaign,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Awareness Voice Notes',
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 15.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Play polio awareness message in 3 languages',
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 11.5.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SUMMARY CARD ====================
class _SummaryCard extends StatelessWidget {
  final WorkerController c;
  const _SummaryCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final counts = c.counts;
      final total = c.sectorHouses.length;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  c.readableSector(),
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 16.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  '$total Households Assigned',
                  style: AppTextStyles.regular.copyWith(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 16.w,
              runSpacing: 8.h,
              children: [
                _LegendDot(
                  color: const Color(0xFF34A853),
                  label: '${counts['done']} Done',
                ),
                _LegendDot(
                  color: const Color(0xFFE53935),
                  label: '${counts['refused']} Refused',
                ),
                _LegendDot(
                  color: const Color(0xFFF5A623),
                  label: '${counts['absent']} Absent',
                ),
                _LegendDot(
                  color: const Color(0xFF9E9E9E),
                  label: '${counts['pending']} Pending',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ==================== MAP ====================
class _MapCard extends StatelessWidget {
  final WorkerController c;
  const _MapCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final markers = c.sectorHouses.map((h) {
        final color = c.colorFor(h.status);
        return Marker(
          point: h.coordinates,
          width: 18,
          height: 18,
          child: GestureDetector(
            onTap: () => HouseActionSheet.show(h),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList();

      return Container(
        height: 300.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: c.center ?? const LatLng(33.7090, 73.0525),
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.polio_guard',
              ),
              if (c.boundary != null)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: c.boundary!,
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderColor: Colors.green.shade700,
                      borderStrokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
      );
    });
  }
}

// ==================== LEGEND ====================
class _LegendCard extends StatelessWidget {
  final WorkerController c;
  const _LegendCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final counts = c.counts;
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'House Status Legend',
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 14.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  'Total: ${c.sectorHouses.length} Houses',
                  style: AppTextStyles.regular.copyWith(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 16.w,
              runSpacing: 8.h,
              children: [
                _LegendDot(
                  color: const Color(0xFF34A853),
                  label: '${counts['done']} Done',
                ),
                _LegendDot(
                  color: const Color(0xFFE53935),
                  label: '${counts['refused']} Refused',
                ),
                _LegendDot(
                  color: const Color(0xFFF5A623),
                  label: '${counts['absent']} Absent',
                ),
                _LegendDot(
                  color: const Color(0xFF9E9E9E),
                  label: '${counts['pending']} Pending',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ==================== HOUSEHOLD LIST (first 5) ====================
class _HouseholdPreviewList extends StatelessWidget {
  final WorkerController c;
  const _HouseholdPreviewList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final preview = c.sectorHouses.take(5).toList();

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: List.generate(preview.length, (index) {
            final house = preview[index];
            final household = _toHousehold(house);

            return Column(
              children: [
                HouseholdTile(
                  household: household,
                  onTap: () => HouseActionSheet.show(house),
                ),
                if (index != preview.length - 1)
                  Divider(height: 1.h, color: Colors.grey.shade200),
              ],
            );
          }),
        ),
      );
    });
  }

  Household _toHousehold(HouseRow h) {
    HouseholdStatus hs;
    switch (h.status) {
      case 'vaccinated':
        hs = HouseholdStatus.done;
        break;
      case 'refused':
        hs = HouseholdStatus.refused;
        break;
      case 'absent':
        hs = HouseholdStatus.absent;
        break;
      default:
        hs = HouseholdStatus.pending;
    }

    return Household(
      id: h.id,
      familyName: h.familyName,
      laneBlock: h.address,
      status: hs,
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
}

// ==================== SHARED LEGEND DOT ====================
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: AppTextStyles.medium.copyWith(
            fontSize: 11.sp,
            color: const Color(0xFF3A3A3A),
          ),
        ),
      ],
    );
  }
}