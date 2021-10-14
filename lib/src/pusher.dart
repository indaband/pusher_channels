import 'package:pusher_dart/pusher_dart.dart';

class Pusher {
  final String url = '.pusher.com:443';
  final String cluster;
  final String client = 'pusher.dart';
  final String key;
  final String version = '0.1.0';
  final int protocol = 6;

  late final Connection connection;
  final Map<String, Channel> channels = {};

  Pusher({required this.key, this.cluster = 'eu', Connection? connection}) {
    this.connection = connection ??
        Connection(
          url:
              'wss://ws-$cluster.$url/app/$key?client=$client&version=$version&protocol=$protocol',
          eventHandler: connectionHandler,
        );
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
  }
}
