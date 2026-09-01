import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/household_model.dart';

/// A lightweight decorative stand-in for a real map, so the Home screen
/// can be built without wiring up google_maps_flutter yet. Swap this out
/// for a real GoogleMap widget once you add the map package + API key.
class MapPlaceholder extends StatelessWidget {
  final double height;

  const MapPlaceholder({super.key, this.height = 220});

  // Fractional (x, y) positions within the map box + the status color to show there.
  static const List<_PinSpec> _pins = [
    _PinSpec(0.30, 0.18, HouseholdStatus.refused),
    _PinSpec(0.62, 0.15, HouseholdStatus.done),
    _PinSpec(0.22, 0.32, HouseholdStatus.absent),
    _PinSpec(0.50, 0.30, HouseholdStatus.done),
    _PinSpec(0.68, 0.35, HouseholdStatus.done),
    _PinSpec(0.40, 0.45, HouseholdStatus.pending),
    _PinSpec(0.78, 0.48, HouseholdStatus.done),
    _PinSpec(0.15, 0.55, HouseholdStatus.done),
    _PinSpec(0.55, 0.58, HouseholdStatus.done),
    _PinSpec(0.35, 0.68, HouseholdStatus.done),
    _PinSpec(0.20, 0.80, HouseholdStatus.pending),
    _PinSpec(0.72, 0.78, HouseholdStatus.refused),
    _PinSpec(0.85, 0.62, HouseholdStatus.done),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: height.h,
        width: double.infinity,
        color: const Color(0xFFE9EDF3),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Faint decorative "roads"
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _RoadsPainter(),
                ),
                // Status pins
                for (final pin in _pins)
                  Positioned(
                    left: pin.dx * constraints.maxWidth - 5,
                    top: pin.dy * constraints.maxHeight - 5,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: pin.status.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PinSpec {
  final double dx;
  final double dy;
  final HouseholdStatus status;

  const _PinSpec(this.dx, this.dy, this.status);
}

class _RoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5C77E).withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.25), paint);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.7), paint);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.4, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.7, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}