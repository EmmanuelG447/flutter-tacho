import 'package:flutter/material.dart';
import 'liquid_progress_indicator/liquid_progress_indicator.dart';
import 'mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Humidity Level App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HumidityLevelScreen(),
    );
  }
}

class HumidityLevelScreen extends StatefulWidget {
  const HumidityLevelScreen({super.key});

  @override
  HumidityLevelScreenState createState() => HumidityLevelScreenState();
}

class HumidityLevelScreenState extends State<HumidityLevelScreen> {
  late MqttService _mqttService;
  double _humidityLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService('broker.emqx.io', '');
    _mqttService.getHumidityLevelStream().listen((humidityLevel) {
      setState(() {
        _humidityLevel = humidityLevel;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Humidity Level Gauge'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: LiquidCircularProgressIndicator(
              value: _humidityLevel / 100,
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              borderColor: Colors.blue,
              borderWidth: 5.0,
              direction: Axis.vertical,
              center: Text(
                '${_humidityLevel.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
