class Channel {
  Channel({required this.name});

  final String name;
  Map<String, Function(dynamic event)> eventCallbacks = {};

  void bind(String eventName, Function(dynamic event) callback) {
    eventCallbacks[eventName] = callback;
  }

  void handleEvent(String eventName, Map<String, dynamic> data) {
    if (eventCallbacks.containsKey(eventName)) {
      eventCallbacks[eventName]?.call(data);
    }
  }
}
