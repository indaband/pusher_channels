import 'package:mocktail/mocktail.dart';
import 'package:pusher_channels/pusher_channels.dart';
import 'package:test/test.dart';

class MockConnection extends Mock implements Connection {}

class MockChannel extends Mock implements Channel {}

void main() {
  group('Pusher', () {
    late Pusher pusher;

    setUp(() {
      pusher = Pusher(key: 'my-key', connection: MockConnection());
    });

    tearDown(() {
      reset(pusher.connection);
    });

    test('connect', () async {
      when(
        () => pusher.connection.connect(),
      ).thenAnswer(
        (_) async => Future.value(null),
      );

      await pusher.connect();

      verify(
        () => pusher.connection.connect(),
      ).called(1);
    });

    test('disconnect', () {
      pusher.disconnect();

      verify(
        () => pusher.connection.disconnect(),
      ).called(1);
    });

    test('subscribe', () {
      final channel = pusher.subscribe('channel-name');

      expect(pusher.channels['channel-name'], channel);
      expect(channel.name, 'channel-name');

      verify(
        () => pusher.connection.sendEvent(
          'pusher:subscribe',
          {'channel': 'channel-name'},
        ),
      ).called(1);
    });

    test('unsubscribe', () {
      pusher.subscribe('channel-name');
      pusher.unsubscribe('channel-name');

      expect(pusher.channels.containsKey('channel-name'), false);
      verify(
        () => pusher.connection.sendEvent(
          'pusher:unsubscribe',
          {'channel': 'channel-name'},
        ),
      ).called(1);
    });

    test('connectionHandler', () {
      final mockChannel = MockChannel();
      pusher.channels['channel-name'] = mockChannel;
      pusher.connectionHandler('event-name', 'channel-name', {'key': 'value'});

      verify(
        () => mockChannel.handleEvent(
          'event-name',
          {'key': 'value'},
        ),
      ).called(1);
    });
  });
}
