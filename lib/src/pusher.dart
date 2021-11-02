import 'package:pusher_channels/pusher_channels.dart';
import 'package:pusher_channels/src/not_initialized.dart';

typedef PusherGlobalCallback = void Function(
    String channelName, String eventName, dynamic data);

class Pusher {
  Connection? _connection;

  final String version = '0.1.3';
  final int protocol = 6;

  PusherGlobalCallback? globalCallback;
  final Map<String, Channel> channels = {};

  Pusher();

  Connection get connection {
    if (_connection == null) {
      throw NotInitialized();
    }
    return _connection!;
  }

  set connection(Connection connection) {
    _connection = connection;
  }

  Future<void> connect() async {
    return connection.connect();
  }

  void disconnect() {
    connection.disconnect();
  }

  Channel subscribe(String channelName) {
    final data = {'channel': channelName};
    connection.sendEvent('pusher:subscribe', data);
    final channel = Channel(name: channelName);
    channels[channelName] = channel;
    return channel;
  }

  void unsubscribe(String channelName) {
    if (channels.containsKey(channelName)) {
      final data = {'channel': channelName};
      channels.remove(channelName);
      connection.sendEvent('pusher:unsubscribe', data);
    }
  }

  void connectionHandler(
      String eventName, String channelName, Map<String, dynamic> data) {
    channels[channelName]?.handleEvent(eventName, data);
    globalCallback?.call(channelName, eventName, data);
  }

  void bindGlobal(PusherGlobalCallback callback) {
    globalCallback = callback;
  }

  void unbindGlobal() {
    globalCallback = null;
  }
}
