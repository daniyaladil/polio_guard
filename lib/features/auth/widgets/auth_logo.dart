import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

class AuthLogo extends StatelessWidget {
  final double size;

  const AuthLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(
        Icons.shield_outlined,
        color: Colors.white,
        size: (size * 0.5).w,
      ),
    );
  }
}