import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef VoidCallback = void Function();
typedef EventHandler = void Function(
    String eventName, String channelName, Map<String, dynamic> data);

class Connection {
  final String url;
  WebSocket? _socket;
  final Map<String, Function(dynamic event)> _eventCallbacks = {};
  final EventHandler eventHandler;
  bool pongReceived = false;
  Timer? _checkPongTimer;

  Connection({
    required this.url,
    required this.eventHandler,
  }) {
    bind('pusher:connection_established', _connect_handler);
    bind('pusher:pong', _pongHandler);
    bind('pusher:error', _pusher_error_handler);
  }

  void _connect_handler(data) {
    print('Connection: Establisheds first connection $data');
  }

  void _pongHandler(data) {
    pongReceived = true;
  }

  void _checkPong() {
    if (pongReceived) {
      pongReceived = false;
      sendPing();
      return;
    }

    disconnect();
    connect();
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
    _socket?.close();
    _checkPongTimer?.cancel();
  }

  Future<void> connect() async {
    _socket = await WebSocket.connect(url);
    _socket?.listen(onMessage);
    sendPing();
    _resetCheckPong();
  }

  void _resetCheckPong() {
    _checkPongTimer?.cancel();
    _checkPongTimer =
        Timer.periodic(Duration(seconds: 60), (timer) => _checkPong());
  }

  void onMessage(data) {
    _resetCheckPong();
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
    _socket?.add(jsonEncode(event));
  }

  void sendPing() {
    sendEvent('pusher:ping', {'data': ''});
  }
}
