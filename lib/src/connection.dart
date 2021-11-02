import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef VoidCallback = void Function();
typedef EventHandler = void Function(
    String eventName, String channelName, Map<String, dynamic> data);

class Connection {
  late final String url;
  late final WebSocket _socket;
  final Map<String, Function(dynamic event)> _eventCallbacks = {};
  final EventHandler eventHandler;

  Connection({
    required this.eventHandler,
    required String url,
    required String key,
    required String version,
    required String protocol,
    bool secure = true,
    String? client,
  }) {
    this.url = '${secure ? 'wss' : 'ws'}://$url/app/$key?${client != null ? 'client=$client&' : ''}version=$version&protocol=$protocol';

    bind('pusher:connection_established', _connect_handler);
    bind('pusher:ping', _ping_handler);
    bind('pusher:error', _pusher_error_handler);
  }

  void _connect_handler(data) {
    print('Connection: Establisheds first connection $data');
  }

  void _ping_handler(data) {
    sendPong();
  }

  void _pusher_error_handler(data) {
    if (data.containsKey('code')) {
      print('ERROR HANDLER code: ${data["code"]}');
    } else {
      print('Connection: No error code supplied');
    }
  }

  void bind(String eventName, Function(dynamic event) callback) {
    _eventCallbacks[eventName] = callback;
  }

  void disconnect() {
    _socket.close();
  }

  Future<void> connect() async {
    _socket = await WebSocket.connect(url);
    _socket.listen(onMessage);
    sendPing();
  }

  void onMessage(data) {
    final json = jsonDecode(data);
    if (json.containsKey('channel')) {
      eventHandler(json['event'], json['channel'], jsonDecode(json['data']));
    } else {
      _eventCallbacks[json['event']]?.call(json['data'] ?? {});
    }
  }

  void sendEvent(String eventName, Map<String, String> data) {
    final event = {
      'event': eventName,
      'data': data,
    };
    _socket.add(jsonEncode(event));
  }

  void sendPing() {
    sendEvent('pusher:ping', {'data': ''});
  }

  void sendPong() {
    sendEvent('pusher:pong', {'data': ''});
  }
}
