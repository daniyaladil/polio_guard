import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/houses_data.dart';
import '../../../core/services/map_service.dart';
import '../data/dummy_data.dart';
import '../model/household_model.dart';
import '../widgets/household_tile.dart';
import 'all_households.dart';
import 'household_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _assignedSector;
  List<LatLng>? _boundary;
  LatLng? _center;
  bool _isLoading = true;

  // Houses for this worker's sector
  List<HouseData> _sectorHouses = [];

  @override
  void initState() {
    super.initState();
    _loadWorkerData();
  }

  Future<void> _loadWorkerData() async {
    final user = Get.find<FirebaseService>().currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    final userData = await Get.find<FirebaseService>().getUserData(user.uid);
    if (userData == null) {
      setState(() => _isLoading = false);
      return;
    }

    final sector = userData['assignedSector'] as String?;
    if (sector == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _assignedSector = sector;
      _boundary = MapService.getBoundary(sector);
      _center = MapService.getCenter(sector);
      _sectorHouses = WorkerMapData.housesInSector(sector);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              style: AppTextStyles.bold.copyWith(
                fontSize: 17.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              radius: 15.r,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assignedSector == null
          ? const Center(child: Text('No sector assigned'))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Sector summary ----
            _buildSummaryCard(),
            SizedBox(height: 16.h),

            // ---- Map (worker's sector only) ----
            _buildSectorMap(),
            SizedBox(height: 16.h),

            // ---- Legend (same as admin) ----
            _buildLegend(),
            SizedBox(height: 20.h),

            // ---- Nearby households header ----
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
                  onTap: () => Get.to(
                        () => AllHouseholdsScreen(
                      sector: _assignedSector!,
                    ),
                  ),
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

            // ---- First 5 households ----
            _buildHouseholdList(),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _buildSummaryCard() {
    final counts = WorkerMapData.statusCounts(_assignedSector!);
    final total = _sectorHouses.length;

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
                WorkerMapData.readableSector(_assignedSector!),
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
                color: HouseholdStatus.done.color,
                label: '${counts[HouseholdStatus.done]} Done',
              ),
              _LegendDot(
                color: HouseholdStatus.refused.color,
                label: '${counts[HouseholdStatus.refused]} Refused',
              ),
              _LegendDot(
                color: HouseholdStatus.absent.color,
                label: '${counts[HouseholdStatus.absent]} Absent',
              ),
              _LegendDot(
                color: HouseholdStatus.pending.color,
                label: '${counts[HouseholdStatus.pending]} Pending',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= SECTOR MAP =================
  Widget _buildSectorMap() {
    // Build markers from the worker's own houses only.
    final markers = _sectorHouses.map((h) {
      return Marker(
        point: h.coordinates,
        width: 18,
        height: 18,
        child: GestureDetector(
          onTap: () {
            // Same bottom-sheet style as admin (reuse HouseholdDetail later)
            final household = WorkerMapData.toHousehold(h);
            Get.to(() => HouseholdDetailScreen(household: household));
          },
          child: Container(
            decoration: BoxDecoration(
              color: h.statusColor,
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
            initialCenter: _center ?? const LatLng(33.7090, 73.0525),
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.polio_guard',
            ),
            // Only this worker's sector boundary
            if (_boundary != null)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: _boundary!,
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderColor: Colors.green.shade700,
                    borderStrokeWidth: 4,
                  ),
                ],
              ),
            // Only this worker's house markers
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }

  // ================= LEGEND =================
  Widget _buildLegend() {
    final counts = WorkerMapData.statusCounts(_assignedSector!);

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
                'Total: ${_sectorHouses.length} Houses',
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
                color: HouseholdStatus.done.color,
                label: '${counts[HouseholdStatus.done]} Done',
              ),
              _LegendDot(
                color: HouseholdStatus.refused.color,
                label: '${counts[HouseholdStatus.refused]} Refused',
              ),
              _LegendDot(
                color: HouseholdStatus.absent.color,
                label: '${counts[HouseholdStatus.absent]} Absent',
              ),
              _LegendDot(
                color: HouseholdStatus.pending.color,
                label: '${counts[HouseholdStatus.pending]} Pending',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= HOUSEHOLD LIST (first 5) =================
  Widget _buildHouseholdList() {
    final all = WorkerMapData.householdsInSector(_assignedSector!);
    final preview = all.take(4).toList();

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
          final household = preview[index];
          return Column(
            children: [
              HouseholdTile(
                household: household,
                onTap: () => Get.to(
                      () => HouseholdDetailScreen(household: household),
                ),
              ),
              if (index != preview.length - 1)
                Divider(height: 1.h, color: Colors.grey.shade200),
            ],
          );
        }),
      ),
    );
  }
}

// ================= SMALL HELPER WIDGET =================
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