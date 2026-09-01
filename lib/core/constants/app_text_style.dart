import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get regular => GoogleFonts.epilogue(
    fontWeight: FontWeight.w400,
    fontSize: 14.sp,
    letterSpacing: 0,
    height: 0,
    color: Colors.black,
  );

  static TextStyle get medium => GoogleFonts.epilogue(
    fontWeight: FontWeight.w500,
    fontSize: 14.sp,
    letterSpacing: 0,
    height: 0,
    color: Colors.black,
  );

  static TextStyle get semiBold => GoogleFonts.epilogue(
    fontWeight: FontWeight.w600,
    fontSize: 14.sp,
    letterSpacing: 0,
    height: 0,
    color: Colors.black,
  );

  static TextStyle get bold => GoogleFonts.epilogue(
    fontWeight: FontWeight.w700,
    fontSize: 14.sp,
    letterSpacing: 0,
    height: 0,
    color: Colors.black,
  );
}