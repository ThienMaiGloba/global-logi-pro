import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  void connect(String url) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
    }
  }

  void broadcastUpdate(String eventType, Map<String, dynamic> payload) {
    if (_isConnected && _channel != null) {
      final message = jsonEncode({'event': eventType, 'data': payload});
      _channel!.sink.add(message);
    }
  }

  Stream<dynamic>? get stream => _channel?.stream;

  void disconnect() {
    if (_isConnected && _channel != null) {
      _channel!.sink.close();
      _isConnected = false;
    }
  }
}
