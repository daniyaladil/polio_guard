// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:polio_guard/core/services/firebase_service.dart';
// import 'package:polio_guard/core/services/map_service.dart';
//
// class WorkerDashboard extends StatefulWidget {
//   const WorkerDashboard({super.key});
//
//   @override
//   State<WorkerDashboard> createState() => _WorkerDashboardState();
// }
//
// class _WorkerDashboardState extends State<WorkerDashboard> {
//   String? _assignedSector;
//   List<LatLng>? _boundary;
//   LatLng? _center;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadWorkerData();
//   }
//
//   Future<void> _loadWorkerData() async {
//     final user = Get.find<FirebaseService>().currentUser;
//     if (user != null) {
//       final userData = await Get.find<FirebaseService>().getUserData(user.uid);
//       if (userData != null) {
//         setState(() {
//           _assignedSector = userData['assignedSector'];
//           _boundary = MapService.getBoundary(_assignedSector!);
//           _center = MapService.getCenter(_assignedSector!);
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Worker Dashboard'),
//         backgroundColor: Colors.green.shade700,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await Get.find<FirebaseService>().signOut();
//               Get.offAllNamed('/login');
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           // Info Card
//           Container(
//             padding: EdgeInsets.all(16.w),
//             margin: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: Colors.green.shade200),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.green.shade700),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Assigned Area,msa,md',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       Text(
//                         MapService.getReadableName(_assignedSector ?? 'Unknown'),
//                         style: TextStyle(
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green.shade900,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Map
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12.r),
//                 child: FlutterMap(
//                   options: MapOptions(
//                     initialCenter: _center ?? const LatLng(33.7090, 73.0525),
//                     initialZoom: 15.0,
//                     interactionOptions: const InteractionOptions(
//                       flags: InteractiveFlag.all,
//                     ),
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                       userAgentPackageName: 'com.example.polio_guard',
//                     ),
//
//                     // Show boundary polygon if available
//                     if (_boundary != null)
//                       PolygonLayer(
//                         polygons: [
//                           Polygon(
//                             points: _boundary!,
//                             color: Colors.green.withOpacity(0.3),
//                             borderColor: Colors.green.shade700,
//                             borderStrokeWidth: 3,
//                           ),
//                         ],
//                       ),
//
//                     // Show center marker
//                     MarkerLayer(
//                       markers: [
//                         Marker(
//                           point: _center ?? const LatLng(33.7090, 73.0525),
//                           width: 40.w,
//                           height: 40.w,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade700,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   blurRadius: 4,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.person_pin,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Bottom Info
//           Container(
//             padding: EdgeInsets.all(16.w),
//             margin: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: Colors.blue.shade200),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.info, color: Colors.blue.shade700),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     'This is your assigned area. You can see the highlighted sector boundaries.',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       color: Colors.blue.shade700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }