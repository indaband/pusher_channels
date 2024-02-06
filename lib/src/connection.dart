import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef VoidCallback = void Function();
typedef EventHandler = void Function(
  String eventName,
  String channelName,
  Map<String, dynamic> data,
);

const _kCheckPongInternal = Duration(seconds: 60);
const _kCheckConnectionInterval = Duration(seconds: 1);

class Connection {
  final String url;
  WebSocket? _socket;
  final Map<String, Function(dynamic event)> _eventCallbacks = {};
  final EventHandler eventHandler;
  bool pongReceived = false;
  Timer? _checkPongTimer;
  Timer? _checkConnectionTimer;
  VoidCallback afterConnect;

  Connection({
    required this.url,
    required this.eventHandler,
    required this.afterConnect,
  }) {
    bind('pusher:connection_established', _connectHandler);
    bind('pusher:pong', _pongHandler);
    bind('pusher:error', _pusherErrorHandler);
  }

  void _connectHandler(data) {
    print('Connection: Establisheds first connection $data');
  }

  void _pongHandler(data) {
    pongReceived = true;
  }

  void _checkConnection() {
    if (_socket?.closeCode != null) {
      reconnect();
    }
  }

  void _checkPong() {
    if (pongReceived) {
      pongReceived = false;
      sendPing();
      return;
    }
  }

  void reconnect() {
    disconnect();
    connect();
  }

  void _pusherErrorHandler(data) {
    if (data.containsKey('code')) {
      print('ERROR HANDLER code: ${data["code"]}');

      if (data['code'] >= 4200 && data['code'] < 4300) {
        reconnect();
      }
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
    try {
      _socket = await WebSocket.connect(url);
      _socket?.listen(onMessage);
      sendPing();
      _resetCheckPong();

      afterConnect();
    } catch (error) {
      print('Connection: connection error $error');
    }

    _resetCheckConnection();
  }

  void _resetCheckConnection() {
    _checkConnectionTimer?.cancel();
    _checkConnectionTimer = Timer.periodic(
      _kCheckConnectionInterval,
      (timer) => _checkConnection(),
    );
  }

  void _resetCheckPong() {
    _checkPongTimer?.cancel();
    _checkPongTimer = Timer.periodic(
      _kCheckPongInternal,
      (timer) => _checkPong(),
    );
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

  void sendEvent(
    String eventName,
    dynamic data, {
    String channelName = '',
  }) {
    final event = {
      'event': eventName,
      'data': data,
    };

    if (channelName.isNotEmpty) {
      event['channel'] = channelName;
    }

    _socket?.add(jsonEncode(event));
  }

  void sendPing() {
    sendEvent('pusher:ping', {'data': ''});
  }
}
