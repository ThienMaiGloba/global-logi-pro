import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttService {
  late MqttBrowserClient client;

  Future<void> initializeClient() async {
    client = MqttBrowserClient('wss://broker.emqx.io:8084/mqtt', 'global_logi_web_${DateTime.now().millisecondsSinceEpoch}');
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.autoReconnect = true;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('global_logi_web_client')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      client.disconnect();
    }
  }
}
