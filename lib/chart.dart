import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DayData {
  final int day;
  final double value;

  DayData(this.day, this.value);
}

class ChartWidget extends StatefulWidget {
  const ChartWidget({super.key});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  int _selectedDay = -1;

  late ChartSeriesController _linerSeriesController;

  final List<DayData> chartData = [
    DayData(0, 30),
    DayData(1, 40),
    DayData(2, 35),
    DayData(3, 50),
    DayData(4, 60),
    DayData(5, 55),
    DayData(6, 45),
  ];

  double get maxYAxis => chartData.reduce((current, next) => current.value > next.value ? current : next).value * 1.3;

  Color middleMarkerColor(int index) => _selectedDay == index ? const Color(0xff572CD1) : Colors.transparent;
  Color markerColor(int index) => _selectedDay == index ? const Color(0xff572CD1) : const Color(0xffF1EEFC);
  Color lineColor(int index) => _selectedDay == index ? const Color(0xff572CD1) : const Color(0xffF1EEFC);

  void _onSelectDay(int day) => setState(() {
        _selectedDay = day;
      });

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext details) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0.0,
      primaryXAxis: CategoryAxis(
        isVisible: false,
        labelPlacement: LabelPlacement.onTicks,
        minimum: -0.1,
        maximum: 6.1,
      ),
      primaryYAxis: NumericAxis(
        isVisible: false,
        minimum: -3,
        maximum: maxYAxis + 2.0,
      ),
      onChartTouchInteractionUp: (detail) {
        final result = _linerSeriesController.pixelToPoint(detail.position);
        int index = (result.x as double).round();
        _onSelectDay(index);
      },
      series: <ChartSeries>[
        // Main chart
        SplineAreaSeries<DayData, int>(
          enableTooltip: false,
          dataSource: chartData,
          xValueMapper: (DayData data, _) => data.day,
          yValueMapper: (DayData data, _) => data.value,
          gradient: const LinearGradient(
            colors: <Color>[Color(0xffE1D9FA), Color(0xffFAFBFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        /// Bottom Markers
        ScatterSeries<DayData, int>(
          dataSource: chartData,
          xValueMapper: (DayData data, _) => data.day,
          yValueMapper: (DayData data, _) => -1,
          pointColorMapper: (_, index) => markerColor(index),
          enableTooltip: false,
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            borderWidth: 0,
            width: 10,
            height: 10,
          ),
        ),

        /// Top Markers
        ScatterSeries<DayData, int>(
          dataSource: chartData,
          xValueMapper: (DayData data, _) => data.day,
          yValueMapper: (DayData data, _) => maxYAxis,
          pointColorMapper: (_, index) => markerColor(index),
          enableTooltip: false,
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            borderWidth: 0,
            width: 10,
            height: 10,
          ),
        ),

        /// Middle Markers
        ScatterSeries<DayData, int>(
          dataSource: chartData,
          xValueMapper: (DayData data, _) => data.day,
          yValueMapper: (DayData data, _) => data.value,
          pointColorMapper: (data, _) => middleMarkerColor(data.day),
          enableTooltip: false,
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            borderWidth: 0,
            width: 10,
            height: 10,
          ),
        ),

        /// Draw line from bottom marker to top marker
        /// [markerSettings.height] only for call [onPointTap] not to show marker
        for (var data in chartData)
          LineSeries<DayData, int>(
            dataSource: [
              DayData(data.day, -1), // Bottom marker
              DayData(data.day, maxYAxis) // Top marker
            ],
            pointColorMapper: (_, index) => lineColor(data.day),
            onRendererCreated: (controller) => _linerSeriesController = controller,
            onPointTap: (ChartPointDetails details) {
              // _onSelectDay(data.day);
            },
            xValueMapper: (DayData data, _) => data.day,
            yValueMapper: (DayData data, _) => data.value,
            width: 1,
            enableTooltip: false,
            markerSettings: const MarkerSettings(
              isVisible: false,
              shape: DataMarkerType.circle,
              width: 10.0,
              height: 10.0,
            ),
          ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}
