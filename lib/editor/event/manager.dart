typedef EventCallback = void Function(EventBody eventBody);

class EventManager {
  final _listeners = <EventListener>[];

  EventManager();

  void emit(EventType eventType, {Map<String, dynamic>? arguments}) {
    var eventBody = EventBody(eventType: eventType, arguments: arguments);
    for (var listener in _listeners) {
      var types = listener.types;
      if (types != null) {
        if (!types.contains(eventType)) {
          continue;
        }
      }
      listener.callback(eventBody);
      eventBody.previous.add(listener.name);
    }
  }

  void addListener(EventListener listener) {
    _listeners.add(listener);
  }

  void removeListenerByName(String name) {
    _listeners.removeWhere((element) => element.name == name);
  }

  void removeListener(EventListener listener) {
    _listeners.remove(listener);
  }
}

enum EventType { contentChanged, disposed, initState }

class EventBody {
  EventType eventType;
  List<String> previous = [];
  Map<String, dynamic>? arguments;
  dynamic lastReturns;

  EventBody({
    required this.eventType,
    this.arguments,
  });
}

class EventListener {
  String name;
  List<EventType>? types;
  EventCallback callback;

  EventListener({
    required this.name,
    required this.callback,
    this.types,
  });
}
