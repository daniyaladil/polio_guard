import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polio_guard/core/constants/app_colors.dart';
import 'package:polio_guard/core/services/firebase_service.dart';
import '../screens/add_worker_screen.dart';

class ManageWorkersScreen extends StatelessWidget {
  const ManageWorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Workers'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Get.to(() => const AddWorkerScreen()),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: Get.find<FirebaseService>().getWorkers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final workers = snapshot.data?.docs ?? [];

          if (workers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No workers registered yet',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const AddWorkerScreen()),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add First Worker'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5276),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final data = workers[index].data() as Map<String, dynamic>;
              final docId = workers[index].id;

              return _WorkerCard(
                name: data['name'] ?? 'Unknown',
                email: data['email'] ?? 'No email',
                sector: data['assignedSector'] ?? 'Not assigned',
                workerId: docId,
                isActive: data['isActive'] ?? true,
              );
            },
          );
        },
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final String name;
  final String email;
  final String sector;
  final String workerId;
  final bool isActive;

  const _WorkerCard({
    required this.name,
    required this.email,
    required this.sector,
    required this.workerId,
    required this.isActive,
  });

  // Get sector color
  Color _getSectorColor(String sector) {
    switch (sector) {
      case 'F-8_Markaz':
        return Colors.blue;
      case 'F-8_1':
        return Colors.green;
      case 'F-8_2':
        return Colors.orange;
      case 'F-8_3':
        return Colors.purple;
      case 'F-8_4':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSectorShortName(String sector) {
    return sector.replaceAll('F-8_', '');
  }

  @override
  Widget build(BuildContext context) {
    final sectorColor = _getSectorColor(sector);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Sector Color Circle
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: sectorColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getSectorShortName(sector),
                  style: TextStyle(
                    color: sectorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Worker Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: sectorColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          sector.replaceAll('_', '/'),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: sectorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              onSelected: (value) {
                if (value == 'deactivate') {
                  _confirmDeactivate(context);
                } else if (value == 'edit') {
                  // TODO: Edit worker
                  Get.snackbar('Info', 'Edit worker feature coming soon');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'deactivate',
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.block : Icons.check_circle,
                        size: 20,
                        color: isActive ? Colors.red : Colors.green,
                      ),
                      SizedBox(width: 12),
                      Text(
                        isActive ? 'Deactivate' : 'Activate',
                        style: TextStyle(
                          color: isActive ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeactivate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActive ? 'Deactivate Worker?' : 'Activate Worker?'),
        content: Text(
          isActive
              ? 'Are you sure you want to deactivate $name?'
              : 'Activate $name again?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              if (isActive) {
                await Get.find<FirebaseService>().deactivateWorker(workerId);
                Get.snackbar(
                  'Success',
                  'Worker deactivated',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            },
            child: Text(
              isActive ? 'Deactivate' : 'Activate',
              style: TextStyle(
                color: isActive ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}