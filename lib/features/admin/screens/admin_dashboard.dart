import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controller/admin_controller.dart';
import '../screens/add_worker_screen.dart';
import '../screens/manage_workers_screen.dart';
import '../screens/change_password_screen.dart';
import 'analysis_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller
    final AdminController controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5276),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'PolioGuard Admin',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 15.r,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                controller.logout();
              } else if (value == 'change_password') {
                Get.to(() => const ChangePasswordScreen());
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'change_password',
                child: Row(
                  children: [
                    Icon(Icons.password, size: 20),
                    SizedBox(width: 12),
                    Text('Change Password'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text
              Text(
                'Welcome, Administrator',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Manage your polio vaccination campaign',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 16.h),

              // Map with dynamic house markers
              _buildMapWithDynamicMarkers(controller),
              SizedBox(height: 16.h),

              // Legend
              _buildLegend(controller),
              SizedBox(height: 16.h),

              // Add this in the build method after the legend section
              SizedBox(height: 16.h),

              _buildFullAnalysisButton(),
              SizedBox(height: 16.h),

              // Action Buttons
              _buildActionButtons(),
              SizedBox(height: 12.h),
            ],
          ),
        );
      }),
    );
  }
  Widget _buildFullAnalysisButton() {
    return GestureDetector(
      onTap: () => Get.to(() => const AdminAnalysisScreen()),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A5276), Color(0xFF2E86C1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A5276).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, color: Colors.white, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              'See Full Analysis',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward, color: Colors.white, size: 18.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildMapWithDynamicMarkers(AdminController controller) {
    List<Polygon> polygons = [];
    List<Marker> markers = [];

    // Add sector boundaries
    for (var sector in controller.sectors) {
      final boundary = controller.getSectorBoundary(sector);
      final color = controller.sectorColors[sector] ?? Colors.grey;

      if (boundary != null) {
        polygons.add(
          Polygon(
            points: boundary,
            color: color.withOpacity(0.1),
            borderColor: color,
            borderStrokeWidth: 5,
          ),
        );
      }
    }

    // Get marker size based on current zoom
    final markerSize = controller.getMarkerSize(controller.currentZoom.value);
    final fontSize = controller.getFontSize(markerSize);

    // Add house markers with dynamic size
    for (var house in controller.allHouses) {
      markers.add(
        Marker(
          point: house.coordinates,
          width: markerSize,
          height: markerSize,
          child: GestureDetector(
            onTap: () {
              controller.showHouseDetails(house, Get.context!);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: markerSize,
              height: markerSize,
              decoration: BoxDecoration(
                color: house.statusColor,
                borderRadius: BorderRadius.circular(200.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: markerSize > 16 ? 4 : 2,
                    offset: Offset(0, markerSize > 16 ? 2 : 1),
                  ),
                ],
              ),
              child: Icon(Icons.location_on,size: 10,color: Colors.white,)
            ),
          ),
        ),
      );
    }

    return Container(
      height: 350.h,
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
          mapController: controller.mapController,
          options: MapOptions(
            initialCenter: const LatLng(33.7030, 73.0470),
            initialZoom: 14.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            // Use onPositionChanged to track zoom - FIXED null check
            onPositionChanged: (position, hasGesture) {
              if (hasGesture && position.zoom != null) {
                controller.updateZoom(position.zoom!);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.polio_guard',
            ),
            PolygonLayer(polygons: polygons),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(AdminController controller) {
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
                'Sector Legend',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Obx(() => Text(
                'Total: ${controller.allHouses.length} Houses',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              )),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              _LegendItem(
                color: const Color(0xFF1A73E8),
                label: 'F-8 Markaz',
              ),
              _LegendItem(
                color: const Color(0xFF34A853),
                label: 'F-8/1',
              ),
              _LegendItem(
                color: const Color(0xFFFBBC04),
                label: 'F-8/2',
              ),
              _LegendItem(
                color: const Color(0xFF9C27B0),
                label: 'F-8/3',
              ),
              _LegendItem(
                color: const Color(0xFFEA4335),
                label: 'F-8/4',
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 8.h),
          Obx(() => Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              _StatusLegendItem(
                color: const Color(0xFF34A853),
                label: 'Vaccinated',
                count: controller.totalVaccinated.value,
              ),
              _StatusLegendItem(
                color: const Color(0xFFEA4335),
                label: 'Refused',
                count: controller.totalRefused.value,
              ),
              _StatusLegendItem(
                color: const Color(0xFFFBBC04),
                label: 'Absent',
                count: controller.totalAbsent.value,
              ),
              _StatusLegendItem(
                color: const Color(0xFF9E9E9E),
                label: 'Pending',
                count: controller.totalPending.value,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            title: 'Manage Workers',
            icon: Icons.people_outline,
            color: const Color(0xFF1A5276),
            onTap: () => Get.to(() => const ManageWorkersScreen()),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _ActionButton(
            title: 'Add Worker',
            icon: Icons.person_add,
            color: Colors.green.shade700,
            onTap: () => Get.to(() => const AddWorkerScreen()),
          ),
        ),
      ],
    );
  }
}

// ============ Helper Widgets ============

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3A3A3A),
          ),
        ),
      ],
    );
  }
}

class _StatusLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _StatusLegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

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
          '$count $label',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3A3A3A),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}