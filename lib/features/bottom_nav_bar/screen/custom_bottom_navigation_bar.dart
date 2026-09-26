import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _BottomItem(icon: Icons.home_filled, label: 'Home'),
      _BottomItem(icon: Icons.settings, label: 'Settings'),
    ];

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 45.w, vertical: 8.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                items.length,
                    (index) => _NavItem(
                  item: items[index],
                  isSelected: selectedIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _BottomItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(36.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  item.icon,
                  key: ValueKey('icon_${item.label}_$isSelected'),
                  size: 22.r,
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.black.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 2.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.black.withOpacity(0.5),
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem {
  final IconData icon;
  final String label;

  const _BottomItem({required this.icon, required this.label});
}