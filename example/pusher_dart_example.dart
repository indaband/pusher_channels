import 'package:pusher_channels/pusher_channels.dart';

void main() async {
  final pusher = Pusher();
  pusher.connection = Connection(url: 'localhost', key: 'YOUR_APP_KEY', version: pusher.version, protocol: pusher.protocol.toString(), eventHandler: pusher.connectionHandler);
  await pusher.connect();
  final channel = pusher.subscribe('channel');
  channel.bind('event', (event) {
    print('WOW event: $event');
  });
  await Future.delayed(Duration(seconds: 60));
}
