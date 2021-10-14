typedef GlobalCallback = void Function(String eventName, dynamic data);

class Channel {
  Channel({required this.name});

  final String name;
  Map<String, Function(dynamic event)> eventCallbacks = {};
  GlobalCallback? globalCallback;

  void bind(String eventName, Function(dynamic event) callback) {
    eventCallbacks[eventName] = callback;
  }

  void unbind(String eventName) {
    eventCallbacks.remove(eventName);
  }

  void bindGlobal(GlobalCallback callback) {
    globalCallback = callback;
  }

  void handleEvent(String eventName, Map<String, dynamic> data) {
    if (eventCallbacks.containsKey(eventName)) {
      eventCallbacks[eventName]?.call(data);
    }
    globalCallback?.call(eventName, data);
  }
}
