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

class RecordAbsentScreen extends StatefulWidget {
  final HouseRow house;
  const RecordAbsentScreen({super.key, required this.house});

  @override
  State<RecordAbsentScreen> createState() => _RecordAbsentScreenState();
}

class _RecordAbsentScreenState extends State<RecordAbsentScreen> {
  File? _photo;
  bool _uploading = false;

  Future<void> _capture() async {
    await Get.to(
          () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Live Photo',
            style: AppTextStyles.bold.copyWith(
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ),
        body: CameraRecorder(
          mode: CaptureMode.photo,
          onDone: (f) => setState(() => _photo = f),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_photo == null) {
      Get.snackbar('Missing photo', 'Capture a live photo first');
      return;
    }
    setState(() => _uploading = true);

    final user = Get.find<FirebaseService>().currentUser!;
    final userData = await Get.find<FirebaseService>().getUserData(user.uid);

    final url = await CloudinaryService.uploadImage(_photo!);
    if (url == null) {
      setState(() => _uploading = false);
      Get.snackbar('Upload failed', 'Check your internet');
      return;
    }

    final ok = await VisitsService.saveVisit(
      house: widget.house,
      workerId: user.uid,
      workerName: (userData?['name'] ?? 'Worker').toString(),
      type: VisitType.absent,
      mediaUrl: url,
      mediaType: 'image',
    );

    setState(() => _uploading = false);

    if (ok) {
      Get.back(result: 'absent');   // <-- return status
      Get.snackbar('Saved', 'Absence recorded',
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
          'Mark Absent',
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

          if (_photo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(_photo!, height: 220.h, fit: BoxFit.cover),
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
                backgroundColor: const Color(0xFFF5A623),
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
    onTap: _capture,
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
          Icon(Icons.photo_camera, color: AppColors.primaryColor, size: 44.sp),
          SizedBox(height: 8.h),
          Text(
            'Take a live photo of the empty house',
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