import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/map_service.dart';
import '../data/dummy_data.dart';
import '../widgets/household_tile.dart';
import '../widgets/map_placeholder.dart';
import '../widgets/ward_summary_card.dart';
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

  @override
  void initState() {
    super.initState();
    _loadWorkerData();
  }

  Future<void> _loadWorkerData() async {
    final user = Get.find<FirebaseService>().currentUser;
    if (user != null) {
      final userData = await Get.find<FirebaseService>().getUserData(user.uid);
      if (userData != null) {
        setState(() {
          _assignedSector = userData['assignedSector'];
          _boundary = MapService.getBoundary(_assignedSector!);
          _center = MapService.getCenter(_assignedSector!);
          _isLoading = false;
        });
      }
    }
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
              child: Icon(Icons.person_outline, color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            WardSummaryCard(
              wardName: DummyHouseholds.wardName,
              totalAssigned: DummyHouseholds.totalAssigned,
              doneCount: DummyHouseholds.doneCount,
              refusedCount: DummyHouseholds.refusedCount,
              absentCount: DummyHouseholds.absentCount,
              pendingCount: DummyHouseholds.pendingCount,
            ),
            SizedBox(height: 16.h),

            // Map Container with fixed height
            Container(
              height: 250.h, // Fixed height for map
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
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
                    // Show boundary polygon if available
                    if (_boundary != null)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _boundary!,
                            color: AppColors.primaryColor,
                            borderColor: Colors.green.shade700,
                            borderStrokeWidth: 4,
                          ),
                        ],
                      ),
                    // Show center marker
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _center ?? const LatLng(33.7090, 73.0525),
                          width: 40.w,
                          height: 40.w,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_pin,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Households Section
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
                  onTap: () {
                    // TODO: navigate to a full household list screen
                  },
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

            // Household List
            Container(
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
                children: List.generate(DummyHouseholds.list.length, (index) {
                  final household = DummyHouseholds.list[index];
                  return Column(
                    children: [
                      HouseholdTile(
                        household: household,
                        onTap: () => Get.to(
                              () => HouseholdDetailScreen(household: household),
                        ),
                      ),
                      if (index != DummyHouseholds.list.length - 1)
                        Divider(height: 1.h, color: Colors.grey.shade200),
                    ],
                  );
                }),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}