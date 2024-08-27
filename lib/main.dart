import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'liquid_progress_indicator/liquid_progress_indicator.dart';
import 'mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Sensor Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SensorDashboardScreen(),
      debugShowCheckedModeBanner: false, // Quitamos la cinta de debug
    );
  }
}

class SensorDashboardScreen extends StatefulWidget {
  const SensorDashboardScreen({Key? key}) : super(key: key);

  @override
  _SensorDashboardScreenState createState() => _SensorDashboardScreenState();
}

class _SensorDashboardScreenState extends State<SensorDashboardScreen> {
  late MqttService _mqttService;
  final List<SensorData> _mq135Data = [];
  final List<SensorData> _mq2Data = [];
  final List<SensorData> _mq7Data = [];
  ChartSeriesController? _mq135Controller;
  ChartSeriesController? _mq2Controller;
  ChartSeriesController? _mq7Controller;

  double _mq135Value = 0.0;
  double _mq2Value = 0.0;
  double _mq7Value = 0.0;

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService('10.14.55.68', 'flutter_client');

    _mqttService.getMq135Stream().listen((value) {
      setState(() {
        _mq135Value = value;
        _mq135Data.add(SensorData(DateTime.now(), value));
        if (_mq135Data.length > 20) {
          _mq135Data.removeAt(0);
        }
        if (_mq135Controller != null) {
          _mq135Controller!
              .updateDataSource(addedDataIndex: _mq135Data.length - 1);
        }
      });
    });

    _mqttService.getMq2Stream().listen((value) {
      setState(() {
        _mq2Value = value;
        _mq2Data.add(SensorData(DateTime.now(), value));
        if (_mq2Data.length > 20) {
          _mq2Data.removeAt(0);
        }
        if (_mq2Controller != null) {
          _mq2Controller!.updateDataSource(addedDataIndex: _mq2Data.length - 1);
        }
      });
    });

    _mqttService.getMq7Stream().listen((value) {
      setState(() {
        _mq7Value = value;
        _mq7Data.add(SensorData(DateTime.now(), value));
        if (_mq7Data.length > 20) {
          _mq7Data.removeAt(0);
        }
        if (_mq7Controller != null) {
          _mq7Controller!.updateDataSource(addedDataIndex: _mq7Data.length - 1);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          children: [
            buildGauge('MQ-135', _mq135Value),
            buildGauge('MQ-2', _mq2Value),
            buildGauge('MQ-7', _mq7Value),
            buildLineChart('MQ-135 Line Chart', _mq135Data, _mq135Controller),
            buildLineChart('MQ-2 Line Chart', _mq2Data, _mq2Controller),
            buildLineChart('MQ-7 Line Chart', _mq7Data, _mq7Controller),
          ],
        ),
      ),
    );
  }

  Widget buildGauge(String label, double value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LiquidCircularProgressIndicator(
        value:
            (value / 10000).clamp(0.0, 1.0), // Escalado y limitado entre 0 y 1
        valueColor: const AlwaysStoppedAnimation(Colors.blue),
        backgroundColor: Colors.transparent,
        borderColor: Colors.blue,
        borderWidth: 5.0,
        direction: Axis.vertical,
        center: Text(
          '$label\n${value.toStringAsFixed(1)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildLineChart(
      String title, List<SensorData> data, ChartSeriesController? controller) {
    return SfCartesianChart(
      title: ChartTitle(text: title),
      primaryXAxis: DateTimeAxis(),
      primaryYAxis: NumericAxis(
        minimum: 300,
        maximum: 10000,
        interval: 1000, // Ajusta según el rango de tus datos
      ),
      series: <LineSeries<SensorData, DateTime>>[
        LineSeries<SensorData, DateTime>(
          onRendererCreated: (ChartSeriesController chartController) {
            controller = chartController;
          },
          dataSource: data,
          xValueMapper: (SensorData data, _) => data.time,
          yValueMapper: (SensorData data, _) => data.value,
          color: Colors.blue,
        )
      ],
      backgroundColor: Colors.transparent, // Sin fondo gris
    );
  }
}

class SensorData {
  SensorData(this.time, this.value);
  final DateTime time;
  final double value;
}
