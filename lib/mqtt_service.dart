import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final MqttServerClient client;

  MqttService(String server, String clientId)
      : client = MqttServerClient(server, clientId) {
    client.logging(on: true);
    client.setProtocolV311();
    client.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId) // Utiliza el clientId proporcionado
        .startClean()
        .withWillQos(MqttQos.exactlyOnce); // Cambiado a exactlyOnce para QoS 2

    client.connectionMessage = connMessage;
  }

  Stream<double> getMq135Stream() async* {
    await _connectAndSubscribe('sensor/mq135');
    await for (final c in client.updates!) {
      if (c.isNotEmpty) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        yield double.tryParse(pt) ?? 0.0;
      }
    }
  }

  Stream<double> getMq2Stream() async* {
    await _connectAndSubscribe('sensor/mq2');
    await for (final c in client.updates!) {
      if (c.isNotEmpty) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        yield double.tryParse(pt) ?? 0.0;
      }
    }
  }

  Stream<double> getMq7Stream() async* {
    await _connectAndSubscribe('sensor/mq7');
    await for (final c in client.updates!) {
      if (c.isNotEmpty) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        yield double.tryParse(pt) ?? 0.0;
      }
    }
  }

  Future<void> _connectAndSubscribe(String topic) async {
    try {
      await client.connect();
    } catch (e) {
      print('Error al conectar: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Conexión establecida con el broker MQTT.');
      client.subscribe(
          topic, MqttQos.exactlyOnce); // Cambiado a exactlyOnce para QoS 2
    } else {
      print(
          'No se pudo establecer la conexión con el broker MQTT. Estado: ${client.connectionStatus?.state}');
      client.disconnect();
    }
  }
}
