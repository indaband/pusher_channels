typedef GlobalCallback = void Function(String eventName, dynamic data);

class Channel {
  Channel({required this.name});

  final String name;
  Map<String, Function(dynamic event)> eventCallbacks = {};
  GlobalCallback? globalCallback;
  Map<String, GlobalCallback> namedGlobalCallbacks = {};

  void bind(String eventName, Function(dynamic event) callback) {
    eventCallbacks[eventName] = callback;
  }

  void unbind(String eventName) {
    eventCallbacks.remove(eventName);
  }

  void bindGlobal(GlobalCallback callback) {
    globalCallback = callback;
  }

  void unbindGlobal() {
    globalCallback = null;
  }

  void bindNamedGlobal(String callbackName, GlobalCallback callback) {
    namedGlobalCallbacks[callbackName] = callback;
  }

  void unbindNamedGlobal(String callbackName) {
    namedGlobalCallbacks.remove(callbackName);
  }

  void handleEvent(String eventName, Map<String, dynamic> data) {
    if (eventCallbacks.containsKey(eventName)) {
      eventCallbacks[eventName]?.call(data);
    }
    globalCallback?.call(eventName, data);
    for (final callback in namedGlobalCallbacks.values) {
      callback.call(eventName, data);
    }
  }
}
