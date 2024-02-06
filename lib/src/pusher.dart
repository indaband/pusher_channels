import 'package:pusher_channels/pusher_channels.dart';

typedef PusherGlobalCallback = void Function(
    String channelName, String eventName, dynamic data);

class Pusher {
  final String url = 'pusher.com:443';
  final String cluster;
  final String client = 'pusher.dart';
  final String key;
  final String version = '0.5.0';
  final int protocol = 6;

  PusherGlobalCallback? globalCallback;
  late final Connection connection;
  final Map<String, Channel> channels = {};

  Pusher({required this.key, this.cluster = 'eu', Connection? connection}) {
    this.connection = connection ??
        Connection(
          url:
              'wss://ws-$cluster.$url/app/$key?client=$client&version=$version&protocol=$protocol',
          eventHandler: connectionHandler,
          afterConnect: afterConnect,
        );
  }

  Future<void> connect() async {
    return connection.connect();
  }

  void disconnect() {
    connection.disconnect();
  }

  void afterConnect() {
    for (var channel in channels.keys) {
      subscribe(channel);
    }
  }

  Channel subscribe(String channelName) {
    final data = {'channel': channelName};
    connection.sendEvent('pusher:subscribe', data);

    if (channels.containsKey(channelName)) {
      final channel = channels[channelName];
      return channel!;
    }

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
    String eventName,
    String channelName,
    Map<String, dynamic> data,
  ) {
    channels[channelName]?.handleEvent(eventName, data);
    globalCallback?.call(channelName, eventName, data);
  }

  void bindGlobal(PusherGlobalCallback callback) {
    globalCallback = callback;
  }

  void unbindGlobal() {
    globalCallback = null;
  }

  void trigger({
    required String channelName,
    required String eventName,
    dynamic data,
  }) {
    connection.sendEvent(
      eventName,
      data,
      channelName: channelName,
    );
  }
}
