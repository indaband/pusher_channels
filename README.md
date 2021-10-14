`pusher-dart` is a pure Dart pusher channels client.

## Usage

A simple usage example:

```dart
import 'package:pusher_dart/pusher_dart.dart';

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

[tracker]: https://github.com/indaband/pusher-dart/issues
