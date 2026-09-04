import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;

  Future<void> initializeClient() async {
    client = MqttServerClient('broker.hivemq.com', 'global_logi_pro_client_${DateTime.now().millisecondsSinceEpoch}');
    client.port = 1883;
    client.keepAlivePeriod = 60;
    client.autoReconnect = true;
    client.logging(on: false);

    final connMess = MqttConnectMessage()
        .withClientIdentifier('global_logi_pro_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      client.disconnect();
    }
  }
}
