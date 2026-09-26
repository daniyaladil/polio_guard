import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/admin_controller.dart';

class AdminAnalysisScreen extends StatelessWidget {
  const AdminAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5276),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Icon(Icons.analytics, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Full Analysis',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
              _buildSummaryCards(controller),
              SizedBox(height: 16.h),
              _buildPieChartSection(controller),
              SizedBox(height: 16.h),
              _buildSectorDetailsTable(controller),
              SizedBox(height: 16.h),
              _buildWorkerPerformance(controller),
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  // ============ SUMMARY CARDS (LIVE DATA) ============
  Widget _buildSummaryCards(AdminController controller) {
    final stats = controller.overallStats;
    final totalHouses = stats['total']!;
    final vaccinated = stats['vaccinated']!;
    final refused = stats['refused']!;
    final absent = stats['absent']!;
    final pending = stats['pending']!;
    final progress = stats['progress']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Houses',
                value: totalHouses.toString(),
                icon: Icons.home,
                color: const Color(0xFF1A5276),
                subtitle: 'All sectors',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _SummaryCard(
                title: 'Progress',
                value: '$progress%',
                icon: Icons.trending_up,
                color: const Color(0xFF34A853),
                subtitle: 'Vaccination rate',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Vaccinated',
                value: vaccinated.toString(),
                icon: Icons.check_circle,
                color: const Color(0xFF34A853),
                subtitle: totalHouses > 0
                    ? '${((vaccinated / totalHouses) * 100).toStringAsFixed(1)}%'
                    : '0%',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _SummaryCard(
                title: 'Pending',
                value: pending.toString(),
                icon: Icons.pending,
                color: const Color(0xFFFBBC04),
                subtitle: totalHouses > 0
                    ? '${((pending / totalHouses) * 100).toStringAsFixed(1)}%'
                    : '0%',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Refused',
                value: refused.toString(),
                icon: Icons.cancel,
                color: const Color(0xFFEA4335),
                subtitle: totalHouses > 0
                    ? '${((refused / totalHouses) * 100).toStringAsFixed(1)}%'
                    : '0%',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _SummaryCard(
                title: 'Absent',
                value: absent.toString(),
                icon: Icons.person_off,
                color: const Color(0xFF9C27B0),
                subtitle: totalHouses > 0
                    ? '${((absent / totalHouses) * 100).toStringAsFixed(1)}%'
                    : '0%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============ PIE CHART (LIVE DATA) ============
  Widget _buildPieChartSection(AdminController controller) {
    final stats = controller.overallStats;
    final total = stats['total']!;
    final vaccinated = stats['vaccinated']!.toDouble();
    final refused = stats['refused']!.toDouble();
    final absent = stats['absent']!.toDouble();
    final pending = stats['pending']!.toDouble();

    if (total == 0) {
      return _ChartContainer(
        title: 'Vaccination Status Distribution',
        subtitle: 'No data yet',
        child: SizedBox(
          height: 280.h,
          child: Center(
            child: Text(
              'No houses loaded',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    return _ChartContainer(
      title: 'Vaccination Status Distribution',
      subtitle: 'Overall breakdown of house statuses',
      child: SizedBox(
        height: 280.h,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    if (vaccinated > 0)
                      PieChartSectionData(
                        value: vaccinated,
                        color: const Color(0xFF34A853),
                        radius: 60,
                        title: '${vaccinated.toInt()}',
                        titleStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (refused > 0)
                      PieChartSectionData(
                        value: refused,
                        color: const Color(0xFFEA4335),
                        radius: 60,
                        title: '${refused.toInt()}',
                        titleStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (absent > 0)
                      PieChartSectionData(
                        value: absent,
                        color: const Color(0xFF9C27B0),
                        radius: 60,
                        title: '${absent.toInt()}',
                        titleStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (pending > 0)
                      PieChartSectionData(
                        value: pending,
                        color: const Color(0xFFFBBC04),
                        radius: 60,
                        title: '${pending.toInt()}',
                        titleStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PieLegendItem(
                    color: const Color(0xFF34A853),
                    label: 'Vaccinated',
                    value: vaccinated.toInt(),
                    total: total,
                  ),
                  SizedBox(height: 8.h),
                  _PieLegendItem(
                    color: const Color(0xFFEA4335),
                    label: 'Refused',
                    value: refused.toInt(),
                    total: total,
                  ),
                  SizedBox(height: 8.h),
                  _PieLegendItem(
                    color: const Color(0xFF9C27B0),
                    label: 'Absent',
                    value: absent.toInt(),
                    total: total,
                  ),
                  SizedBox(height: 8.h),
                  _PieLegendItem(
                    color: const Color(0xFFFBBC04),
                    label: 'Pending',
                    value: pending.toInt(),
                    total: total,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ SECTOR DETAILS TABLE (LIVE DATA) ============
  Widget _buildSectorDetailsTable(AdminController controller) {
    final sectors = controller.sectors;

    return _ChartContainer(
      title: 'Detailed Sector Statistics',
      subtitle: 'Complete breakdown by sector',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            const Color(0xFF1A5276).withOpacity(0.1),
          ),
          columns: [
            DataColumn(
              label: Text(
                'Sector',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: const Color(0xFF1A5276),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: const Color(0xFF1A5276),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Vaccinated',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: const Color(0xFF34A853),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Pending',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: const Color(0xFFFBBC04),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Refused',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: const Color(0xFFEA4335),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: const Color(0xFF1A5276),
                ),
              ),
            ),
          ],
          rows: sectors.map((sector) {
            final stats = controller.sectorStats(sector);
            final progress = stats['progress']!;
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: _getSectorColor(sector),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        sector.replaceAll('F-8_', 'F-8/').replaceAll('_', ''),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    '${stats['total']}',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ),
                DataCell(
                  Text(
                    '${stats['vaccinated']}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF34A853),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${stats['pending']}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFFFBBC04),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${stats['refused']}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFFEA4335),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(progress).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '$progress%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(progress),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============ WORKER PERFORMANCE (SECTOR-BASED) ============
  Widget _buildWorkerPerformance(AdminController controller) {
    final sectors = controller.sectors;

    return _ChartContainer(
      title: 'Sector Progress Performance',
      subtitle: 'Vaccination rate per sector',
      child: Column(
        children: sectors.map((sector) {
          final stats = controller.sectorStats(sector);
          final total = stats['total']!;
          final vaccinated = stats['vaccinated']!;
          final percentage = stats['progress']!;

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: _getSectorColor(sector).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      sector.replaceAll('F-8_', '').replaceAll('Markaz', 'M'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: _getSectorColor(sector),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sector.replaceAll('F-8_', 'F-8/').replaceAll('_', ''),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: _getProgressColor(percentage),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$vaccinated/$total houses vaccinated',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: total > 0 ? vaccinated / total : 0,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(percentage),
                          ),
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============ HELPER METHODS ============
  Color _getSectorColor(String sector) {
    switch (sector) {
      case 'F-8_Markaz':
        return const Color(0xFF1A73E8);
      case 'F-8_1':
        return const Color(0xFF34A853);
      case 'F-8_2':
        return const Color(0xFFFBBC04);
      case 'F-8_3':
        return const Color(0xFF9C27B0);
      case 'F-8_4':
        return const Color(0xFFEA4335);
      default:
        return Colors.grey;
    }
  }

  Color _getProgressColor(int progress) {
    if (progress >= 70) return const Color(0xFF34A853);
    if (progress >= 40) return const Color(0xFFFBBC04);
    return const Color(0xFFEA4335);
  }
}

// ============ HELPER WIDGETS ============

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 18.sp),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3A3A3A),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartContainer({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _PieLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final int total;

  const _PieLegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
    total > 0 ? (value / total * 100).toStringAsFixed(1) : '0';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3A3A3A),
                ),
              ),
              Text(
                '$value ($percentage%)',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}