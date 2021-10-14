`pusher_channels` is a pure Dart pusher channels client.

This client is work in progress and it is unstable.

## Usage

A simple usage example:

```dart
import 'package:pusher_channels/pusher_channels.dart';

main() {
  final pusher = Pusher(key: 'YOUR_APP_KEY');
  await pusher.connect();
  final channel = pusher.subscribe('channel');
  channel.bind('event', (event) {
    print('WOW event: $event');
  });
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/indaband/pusher_channels/issues
