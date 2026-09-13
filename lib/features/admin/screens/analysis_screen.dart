import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/houses_data.dart';
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
              // Summary Cards
              _buildSummaryCards(controller),
              SizedBox(height: 16.h),

              // Pie Chart - Vaccination Status Distribution
              _buildPieChartSection(controller),
              SizedBox(height: 16.h),

              // Bar Chart - Sector-wise Progress
              _buildBarChartSection(controller),
              SizedBox(height: 16.h),

              // Heatmap
              _buildColorMapSection(controller),
              SizedBox(height: 16.h),

              // Line Chart - Progress Over Time (Simulated)
              _buildProgressLineChart(controller),
              SizedBox(height: 16.h),

              // Sector Details Table
              _buildSectorDetailsTable(controller),
              SizedBox(height: 16.h),

              // Worker Performance
              _buildWorkerPerformance(controller),
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  // ============ SECTOR COLOR MAP ============
  Widget _buildColorMapSection(AdminController controller) {
    final sectors = controller.sectors;

    // Build polygons + markers
    List<Polygon> polygons = [];
    List<Marker> markers = [];

    for (var sector in sectors) {
      final boundary = controller.getSectorBoundary(sector);
      if (boundary == null || boundary.isEmpty) continue;

      final stats = DummyHouseData.getSectorStats(sector);
      final total = stats['total'] as int;
      final vaccinated = stats['vaccinated'] as int;
      final progress = total > 0 ? vaccinated / total : 0.0;

      final color = _coverageColor(progress);

      polygons.add(
        Polygon(
          points: boundary,
          color: color.withOpacity(0.55),   // fill
          borderColor: color,               // outline
          borderStrokeWidth: 3,
        ),
      );
    }

    // Small house dots on top for detail
    for (var house in controller.allHouses) {
      markers.add(
        Marker(
          point: house.coordinates,
          width: 8,
          height: 8,
          child: Container(
            decoration: BoxDecoration(
              color: house.statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      );
    }

    return _ChartContainer(
      title: 'Sector Coverage Color Map',
      subtitle: 'Red = low vaccination, Green = high vaccination',
      child: SizedBox(
        height: 340.h,
        child: Row(
          children: [
            // -------- MAP --------
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(33.7030, 73.0470),
                    initialZoom: 13.0,
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.polio_guard',
                    ),
                    PolygonLayer(polygons: polygons),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // -------- GRADIENT LEGEND (right side) --------
            SizedBox(
              width: 70.w,
              child: _CoverageGradientLegend(sectors: sectors),
            ),
          ],
        ),
      ),
    );
  }


  // ============ SUMMARY CARDS ============
  Widget _buildSummaryCards(AdminController controller) {
    final stats = DummyHouseData.getOverallStats();
    final totalHouses = stats['total'] as int;
    final vaccinated = stats['vaccinated'] as int;
    final refused = stats['refused'] as int;
    final absent = stats['absent'] as int;
    final pending = stats['pending'] as int;
    final progress = stats['progress'] as int;

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
                subtitle: '${((vaccinated / totalHouses) * 100).toStringAsFixed(1)}%',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _SummaryCard(
                title: 'Pending',
                value: pending.toString(),
                icon: Icons.pending,
                color: const Color(0xFFFBBC04),
                subtitle: '${((pending / totalHouses) * 100).toStringAsFixed(1)}%',
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
                subtitle: '${((refused / totalHouses) * 100).toStringAsFixed(1)}%',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _SummaryCard(
                title: 'Absent',
                value: absent.toString(),
                icon: Icons.person_off,
                color: const Color(0xFF9C27B0),
                subtitle: '${((absent / totalHouses) * 100).toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============ PIE CHART ============
  Widget _buildPieChartSection(AdminController controller) {
    final stats = DummyHouseData.getOverallStats();
    final vaccinated = (stats['vaccinated'] as int).toDouble();
    final refused = (stats['refused'] as int).toDouble();
    final absent = (stats['absent'] as int).toDouble();
    final pending = (stats['pending'] as int).toDouble();

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
                    total: stats['total'] as int,
                  ),
                  SizedBox(height: 8.h),
                  _PieLegendItem(
                    color: const Color(0xFFEA4335),
                    label: 'Refused',
                    value: refused.toInt(),
                    total: stats['total'] as int,
                  ),
                  SizedBox(height: 8.h),
                  _PieLegendItem(
                    color: const Color(0xFF9C27B0),
                    label: 'Absent',
                    value: absent.toInt(),
                    total: stats['total'] as int,
                  ),
                  SizedBox(height: 8.h),
                  _PieLegendItem(
                    color: const Color(0xFFFBBC04),
                    label: 'Pending',
                    value: pending.toInt(),
                    total: stats['total'] as int,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ BAR CHART ============
  Widget _buildBarChartSection(AdminController controller) {
    final sectors = controller.sectors;
    final sectorStats = sectors.map((s) => DummyHouseData.getSectorStats(s)).toList();

    return _ChartContainer(
      title: 'Sector-wise Vaccination Progress',
      subtitle: 'Comparison across all sectors',
      child: SizedBox(
        height: 250.h,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()}%',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final sectorName = sectors[value.toInt()]
                        .replaceAll('F-8_', '')
                        .replaceAll('_', '/');
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        sectorName,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3A3A3A),
                        ),
                      ),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  interval: 25,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(sectors.length, (index) {
              final stats = sectorStats[index];
              final progress = (stats['progress'] as int).toDouble();
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: progress,
                    color: _getSectorColor(sectors[index]),
                    width: 20.w,
                    borderRadius: BorderRadius.circular(4.r),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 100,
                      color: Colors.grey.shade100,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // ============ PROGRESS LINE CHART ============
  Widget _buildProgressLineChart(AdminController controller) {
    // Simulated progress data over time (you can replace with actual data)
    final progressData = [
      FlSpot(0, 10),
      FlSpot(1, 25),
      FlSpot(2, 40),
      FlSpot(3, 55),
      FlSpot(4, 70),
      FlSpot(5, 85),
      FlSpot(6, 92),
    ];

    return _ChartContainer(
      title: 'Vaccination Progress Trend',
      subtitle: 'Simulated progress over campaign duration',
      child: SizedBox(
        height: 200.h,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const days = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];
                    if (value.toInt() < days.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          days[value.toInt()],
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  interval: 20,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: progressData,
                isCurved: true,
                color: const Color(0xFF1A5276),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF1A5276),
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF1A5276).withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ SECTOR DETAILS TABLE ============
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
            final stats = DummyHouseData.getSectorStats(sector);
            final progress = stats['progress'] as int;
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

  // ============ WORKER PERFORMANCE ============
  Widget _buildWorkerPerformance(AdminController controller) {
    // Simulated worker data
    final workers = [
      {'name': 'Worker 1', 'houses': 150, 'vaccinated': 120, 'sector': 'F-8/1'},
      {'name': 'Worker 2', 'houses': 200, 'vaccinated': 180, 'sector': 'F-8/2'},
      {'name': 'Worker 3', 'houses': 100, 'vaccinated': 85, 'sector': 'F-8/4'},
    ];

    return _ChartContainer(
      title: 'Worker Performance',
      subtitle: 'Individual worker vaccination rates',
      child: Column(
        children: workers.map((worker) {
          final houses = worker['houses'] as int;
          final vaccinated = worker['vaccinated'] as int;
          final percentage = (vaccinated / houses * 100).round();

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A5276).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      worker['name'].toString().split(' ').last,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A5276),
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
                            worker['name'].toString(),
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
                        '${worker['sector']} • $vaccinated/$houses houses',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: vaccinated / houses,
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
    final percentage = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0';

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
// ============ GRADIENT LEGEND (right side of color map) ============
class _CoverageGradientLegend extends StatelessWidget {
  final List<String> sectors;
  const _CoverageGradientLegend({required this.sectors});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 100% label at top
        Text(
          '100%',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF34A853),
          ),
        ),

        SizedBox(height: 4.h),

        // The gradient bar: green (top) -> yellow -> red (bottom)
        Expanded(
          child: Container(
            width: 22.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1B8A3A), // deep green (100%)
                  Color(0xFF34A853), // green
                  Color(0xFFA5D66A), // yellow-green
                  Color(0xFFFBBC04), // yellow
                  Color(0xFFF57C00), // orange
                  Color(0xFFEA4335), // red
                  Color(0xFF8B0000), // dark red (0%)
                ],
                stops: [0.0, 0.15, 0.35, 0.5, 0.7, 0.85, 1.0],
              ),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // 0% label at bottom
        Text(
          '0%',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEA4335),
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          'Coverage',
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ============ COVERAGE COLOR SCALE ============
/// Maps 0.0 (0%) -> dark red, 0.5 (50%) -> yellow, 1.0 (100%) -> deep green
Color _coverageColor(double coverage) {
  // Clamp
  coverage = coverage.clamp(0.0, 1.0);

  // Define stops (position, color)
  const stops = <double>[
    0.0,   // dark red
    0.25,  // red
    0.5,   // yellow
    0.75,  // yellow-green
    1.0,   // deep green
  ];
  const colors = <Color>[
    Color(0xFF8B0000),
    Color(0xFFEA4335),
    Color(0xFFFBBC04),
    Color(0xFFA5D66A),
    Color(0xFF1B8A3A),
  ];

  for (int i = 0; i < stops.length - 1; i++) {
    if (coverage >= stops[i] && coverage <= stops[i + 1]) {
      final t = (coverage - stops[i]) / (stops[i + 1] - stops[i]);
      return Color.lerp(colors[i], colors[i + 1], t)!;
    }
  }
  return colors.last;
}