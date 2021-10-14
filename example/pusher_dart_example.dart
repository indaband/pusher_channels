import 'package:pusher_dart/pusher_dart.dart';

void main() async {
  final pusher = Pusher(key: 'YOUR_APP_KEY');
  await pusher.connect();
  final channel = pusher.subscribe('channel');
  channel.bind('event', (event) {
    print('WOW event: $event');
  });
  await Future.delayed(Duration(seconds: 60));

}
