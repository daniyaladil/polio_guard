import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/houses_data.dart';
import '../../../core/services/visits_service.dart';
import '../controller/worker_controller.dart';
import '../model/visit_model.dart';
import '../widgets/camera_record.dart';

class RecordVaccinatedScreen extends StatefulWidget {
  final HouseRow house;
  const RecordVaccinatedScreen({super.key, required this.house});

  @override
  State<RecordVaccinatedScreen> createState() => _RecordVaccinatedScreenState();
}

class _RecordVaccinatedScreenState extends State<RecordVaccinatedScreen> {
  final List<_ChildRow> _children = [
    _ChildRow(
        nameCtrl: TextEditingController(), ageCtrl: TextEditingController()),
  ];

  File? _video;
  bool _uploading = false;

  @override
  void dispose() {
    for (final c in _children) {
      c.nameCtrl.dispose();
      c.ageCtrl.dispose();
    }
    super.dispose();
  }

  void _addChild() {
    setState(() {
      _children.add(_ChildRow(
          nameCtrl: TextEditingController(),
          ageCtrl: TextEditingController()));
    });
  }

  void _removeChild(int i) {
    if (_children.length == 1) return;
    setState(() {
      _children[i].nameCtrl.dispose();
      _children[i].ageCtrl.dispose();
      _children.removeAt(i);
    });
  }

  Future<void> _recordVideo() async {
    await Get.to(
          () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Record Proof',
            style: AppTextStyles.bold
                .copyWith(fontSize: 16.sp, color: Colors.white),
          ),
        ),
        body: CameraRecorder(
          mode: CaptureMode.video,
          onDone: (file) => setState(() => _video = file),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    for (var c in _children) {
      if (c.nameCtrl.text.trim().isEmpty || c.ageCtrl.text.trim().isEmpty) {
        Get.snackbar('Missing info', "Fill in every child's name and age");
        return;
      }
    }
    if (_video == null) {
      Get.snackbar('Missing video', 'Record a short proof video first');
      return;
    }

    setState(() => _uploading = true);

    final user = Get.find<FirebaseService>().currentUser!;
    final userData = await Get.find<FirebaseService>().getUserData(user.uid);

    final url = await CloudinaryService.uploadVideo(_video!);
    if (url == null) {
      setState(() => _uploading = false);
      Get.snackbar('Upload failed', 'Check your internet and try again');
      return;
    }

    final ok = await VisitsService.saveVisit(
      house: widget.house,
      workerId: user.uid,
      workerName: (userData?['name'] ?? 'Worker').toString(),
      type: VisitType.vaccinated,
      mediaUrl: url,
      mediaType: 'video',
      children: _children
          .map((c) => VisitedChild(
        name: c.nameCtrl.text.trim(),
        age: c.ageCtrl.text.trim(),
      ))
          .toList(),
    );

    setState(() => _uploading = false);

    if (ok) {
      Get.back(result: 'vaccinated'); // <-- returns the status
      Get.snackbar('Saved', 'Vaccination recorded',
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Error', 'Could not save visit');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Mark Vaccinated',
          style: AppTextStyles.bold
              .copyWith(fontSize: 16.sp, color: Colors.white),
        ),
      ),
      body: _uploading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _houseCard(),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Children Vaccinated',
                style: AppTextStyles.bold.copyWith(
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              TextButton.icon(
                onPressed: _addChild,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add child'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...List.generate(_children.length, (i) {
            final c = _children[i];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Child ${i + 1}',
                        style: AppTextStyles.semiBold.copyWith(
                          fontSize: 12.5.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      if (_children.length > 1)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removeChild(i),
                        ),
                    ],
                  ),
                  TextField(
                    controller: c.nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: c.ageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Age (e.g. 2y, 18m)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 16.h),
          Text(
            'Proof Video',
            style: AppTextStyles.bold.copyWith(
              fontSize: 14.sp,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 8.h),
          _videoPicker(),
          SizedBox(height: 24.h),
          SizedBox(
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                'Submit',
                style: AppTextStyles.bold
                    .copyWith(fontSize: 14.sp, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34A853),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _houseCard() => Container(
    width: double.infinity,
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.house.familyName,
          style: AppTextStyles.bold.copyWith(
            fontSize: 14.5.sp,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          widget.house.address,
          style: AppTextStyles.regular.copyWith(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    ),
  );

  Widget _videoPicker() {
    return InkWell(
      onTap: _recordVideo,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
            _video != null ? const Color(0xFF34A853) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _video != null ? Icons.check_circle : Icons.videocam,
              color: _video != null
                  ? const Color(0xFF34A853)
                  : AppColors.primaryColor,
              size: 40.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              _video != null ? 'Video recorded' : 'Tap to record video',
              style: AppTextStyles.semiBold.copyWith(
                fontSize: 13.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildRow {
  final TextEditingController nameCtrl;
  final TextEditingController ageCtrl;
  _ChildRow({required this.nameCtrl, required this.ageCtrl});
}