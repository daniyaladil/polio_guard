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

class RecordRefusedScreen extends StatefulWidget {
  final HouseRow house;
  const RecordRefusedScreen({super.key, required this.house});

  @override
  State<RecordRefusedScreen> createState() => _RecordRefusedScreenState();
}

class _RecordRefusedScreenState extends State<RecordRefusedScreen> {
  File? _video;
  bool _uploading = false;

  Future<void> _record() async {
    await Get.to(
          () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Record Refusal',
            style: AppTextStyles.bold.copyWith(
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ),
        body: CameraRecorder(
          mode: CaptureMode.video,
          onDone: (f) => setState(() => _video = f),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_video == null) {
      Get.snackbar('Missing video', 'Record the refusal video first');
      return;
    }
    setState(() => _uploading = true);

    final user = Get.find<FirebaseService>().currentUser!;
    final userData = await Get.find<FirebaseService>().getUserData(user.uid);

    final url = await CloudinaryService.uploadVideo(_video!);
    if (url == null) {
      setState(() => _uploading = false);
      Get.snackbar('Upload failed', 'Check your internet');
      return;
    }

    final ok = await VisitsService.saveVisit(
      house: widget.house,
      workerId: user.uid,
      workerName: (userData?['name'] ?? 'Worker').toString(),
      type: VisitType.refused,
      mediaUrl: url,
      mediaType: 'video',
    );

    setState(() => _uploading = false);

    if (ok) {
      Get.back(result: 'refused');   // <-- return status
      Get.snackbar('Saved', 'Refusal recorded',
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
          'Mark Refused',
          style: AppTextStyles.bold.copyWith(
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: _uploading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _houseCard(),
          SizedBox(height: 16.h),
          if (_video != null)
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF34A853), width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle,
                      color: const Color(0xFF34A853), size: 40.sp),
                  SizedBox(height: 8.h),
                  Text(
                    'Refusal video recorded',
                    style: AppTextStyles.semiBold.copyWith(fontSize: 13.sp),
                  ),
                ],
              ),
            )
          else
            _captureCard(),
          SizedBox(height: 24.h),
          SizedBox(
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                'Submit',
                style: AppTextStyles.bold.copyWith(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
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
          style: AppTextStyles.bold.copyWith(fontSize: 14.5.sp),
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

  Widget _captureCard() => InkWell(
    onTap: _record,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.videocam, color: AppColors.primaryColor, size: 44.sp),
          SizedBox(height: 8.h),
          Text(
            'Tap to record refusal video',
            textAlign: TextAlign.center,
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