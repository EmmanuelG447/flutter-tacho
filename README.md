### Paso a Paso para Crear el Proyecto MQTT con Indicador de Progreso Líquido

Este paso a paso te guiará en la creación de un proyecto Flutter que muestra un indicador de progreso líquido circular usando MQTT para obtener datos de nivel de humedad. Se incluyen todos los archivos necesarios y se describen los pasos para configurarlos.

#### 1. Crear el Proyecto Flutter

```bash
flutter create mqtt_humidity_level
cd mqtt_humidity_level
```

#### 2. Estructura del Proyecto

Asegúrate de que tu proyecto tenga la siguiente estructura:

```
mqtt_humidity_level/
├── lib/
│   ├── liquid_progress_indicator/
│   │   ├── liquid_circular_progress_indicator.dart
│   │   ├── liquid_progress_indicator.dart
│   │   ├── pubspec.yaml
│   │   └── wave.dart

│   ├── mqtt_service.dart
│   └── main.dart
├── pubspec.yaml
```

#### 3. Archivo `pubspec.yaml`

Configura el archivo `pubspec.yaml` con las dependencias necesarias:

```yaml
name: mqtt_humidity_level
description: "A new Flutter project."
publish_to: "none"
version: 0.1.0

environment:
  sdk: ">=3.4.3 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  mqtt_client: ^9.6.1
  liquid_progress_indicator:
    path: lib/liquid_progress_indicator

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

#### 4. Archivos del Indicador de Progreso Líquido

##### Archivo `lib/liquid_progress_indicator/pubspec.yaml`

```yaml
name: liquid_progress_indicator
description: A customizable liquid progress indicator for Flutter.
version: 0.4.0

environment:
  sdk: ">=3.4.3 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
```

##### Archivo `lib/liquid_progress_indicator/liquid_progress_indicator.dart`

```dart
library liquid_progress_indicator;

export 'liquid_circular_progress_indicator.dart';
```

##### Archivo `lib/liquid_progress_indicator/liquid_circular_progress_indicator.dart`

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'wave.dart';

const double _twoPi = math.pi * 2.0;
const double _epsilon = .001;
const double _sweep = _twoPi - _epsilon;

class LiquidCircularProgressIndicator extends ProgressIndicator {
  final double? borderWidth;
  final Color? borderColor;
  final Widget? center;
  final Axis direction;

  LiquidCircularProgressIndicator({
    super.key,
    double super.value = 0.5,
    super.backgroundColor,
    Animation<Color>? super.valueColor,
    this.borderWidth,
    this.borderColor,
    this.center,
    this.direction = Axis.vertical,
  }) {
    if (borderWidth != null && borderColor == null ||
        borderColor != null && borderWidth == null) {
      throw ArgumentError("borderWidth and borderColor should both be set.");
    }
  }

  Color _getBackgroundColor(BuildContext context) =>
      backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).hintColor;

  @override
  State<StatefulWidget> createState() =>
      _LiquidCircularProgressIndicatorState();
}

class _LiquidCircularProgressIndicatorState
    extends State<LiquidCircularProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CircleClipper(),
      child: CustomPaint(
        painter: _CirclePainter(
          color: widget._getBackgroundColor(context),
        ),
        foregroundPainter: _CircleBorderPainter(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        child: Stack(
          children: [
            Wave(
              value: widget.value,
              color: widget._getValueColor(context),
              direction: widget.direction,
            ),
            if (widget.center != null) Center(child: widget.center),
          ],
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;

  _CirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawArc(Offset.zero & size, 0, _sweep, false, paint);
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) => color != oldDelegate.color;
}

class _CircleBorderPainter extends CustomPainter {
  final Color? color;
  final double? width;

  _CircleBorderPainter({this.color, this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (color == null || width == null) {
      return;
    }

    final borderPaint = Paint()
      ..color = color!
      ..style = PaintingStyle.stroke
      ..strokeWidth = width!;
    final newSize = Size(size.width - width!, size.height - width!);
    canvas.drawArc(
        Offset(width! / 2, width! / 2) & newSize, 0, _sweep, false, borderPaint);
  }

  @override
  bool shouldRepaint(_CircleBorderPainter oldDelegate) =>
      color != oldDelegate.color || width != oldDelegate.width;
}

class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..addArc(Offset.zero & size, 0, _sweep);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
```

##### Archivo `lib/liquid_progress_indicator/wave.dart`

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class Wave extends StatefulWidget {
  final double? value;
  final Color color;
  final Axis direction;

  const Wave({
    super.key,
    required this.value,
    required this.color,
    required this.direction,
  });

  @override
  WaveState createState() => WaveState();
}

class WaveState extends State<Wave> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
      builder: (context, child) => ClipPath(
        clipper: _WaveClipper(
          animationValue: _animationController.value,
          value: widget.value,
          direction: widget.direction,
        ),
        child: Container(
          color: widget.color,
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double animationValue;
  final double? value;
  final Axis direction;

  _WaveClipper({
    required this.animationValue,
    required this.value,
    required this.direction,
  });

  @override
  Path getClip(Size size) {
    if (direction == Axis.horizontal) {
      Path path = Path()
        ..addPolygon(_generateHorizontalWavePath(size), false)
        ..lineTo(0.0, size.height)
        ..lineTo(0.0, 0.0)
        ..close();
      return path;
    }

    Path path = Path()
      ..addPolygon(_generateVerticalWavePath(size), false)
      ..lineTo(size.width, size.height)
      ..lineTo(0.0, size.height)
      ..close();
    return path;
  }

  List<Offset> _generateHorizontalWavePath(Size size) {
    final waveList = <Offset>[];
    for (int i = -2; i <= size.height.toInt() + 2; i++) {
      final waveHeight = (size.width / 20);
      final dx = math.sin((animationValue * 360 - i) % 360 * (math.pi / 180)) *
              waveHeight +
          (size.width * value!);
      waveList.add(Offset(dx, i.toDouble()));
    }
    return waveList;
  }

  List<Offset> _generateVerticalWavePath(Size size) {
    final waveList = <Offset>[];
    for (int i = -2; i <= size.width.toInt() + 2; i++) {
      final waveHeight = (size.height / 20);
      final dy = math.sin((animationValue * 360 - i) % 360 * (math.pi / 180)) *
              waveHeight +
          (size.height - (size.height * value!));
      waveList.add(Offset(i.toDouble(), dy));
    }
    return waveList;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) =>
      animationValue != oldClipper.animationValue;
}
```

#### 5. Archivo `lib/mqtt_service.dart`

```dart
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final MqttServerClient client;

  MqttService(String server, String clientId)
      : client = MqttServerClient(server, '') {
    const sanitizedClientId = '';

    client.logging(on: true);
    client.setProtocolV311();
    client.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(sanitizedClientId)
       

 .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;
  }

  Stream<double> getHumidityLevelStream() async* {
    try {
      await client.connect();
    } catch (e) {
      client.disconnect();
      return;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.subscribe("humidity/level", MqttQos.atLeastOnce);

      await for (final c in client.updates!) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message);
        yield double.tryParse(pt) ?? 0.0;
      }
    } else {
      client.disconnect();
    }
  }
}
```

#### 6. Archivo `lib/main.dart`

```dart
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
```

### Ejecutar el Proyecto

1. Asegúrate de tener todas las dependencias instaladas.

```bash
flutter pub get
```

2. Corre la aplicación.

```bash
flutter run
```

Con estos pasos, deberías tener una aplicación Flutter que muestra un indicador de progreso líquido circular, con datos de nivel de humedad obtenidos a través de MQTT.