import 'package:cognitive_training/pages/training_series/training_event.dart';

class NsgTimer {
  int startTime = 0;
  int lastEventTime = 0;

  ///Длительность работы таймера, мс
  int timerDuration;

  ///Интервал времени для вызова tickCallback, мс
  int tickDuration = 10;

  ///Функция, вызываемая каждые timerDuration мс
  final void Function(int timeFromStart)? tickCallback;

  ///Функция, вызываемая при обработке события
  final void Function(int timeFromStart, TimerEvents event)? eventCallback;

  ///Функция, вызываемая по окончанию времени работы таймера или при его остановке
  final void Function() stopCallback;
  bool _isStarted = false;
  bool get isStarted => _isStarted;

  ///Список событий, автоматически обрабатываемых таймером
  final List<TimerEvents> _events = <TimerEvents>[];

  NsgTimer(
      {required this.timerDuration,
      this.tickCallback,
      required this.stopCallback,
      List<TimerEvents> events = const [],
      this.tickDuration = 100,
      this.eventCallback}) {
    for (var event in events) {
      event.timer = this;
    }
    _events.addAll(events);
  }

  Future start() async {
    assert(!_isStarted, 'Times already started');
    startTime = DateTime.now().millisecondsSinceEpoch;
    lastEventTime = 0;
    _isStarted = true;
    _loop();
  }

  void pause() {
    throw Exception('Not implemented');
  }

  void stop() {
    if (_isStarted) {
      _isStarted = false;
      stopCallback();
    }
  }

  Future _loop() async {
    while (_isStarted) {
      var currentTime = DateTime.now().millisecondsSinceEpoch - startTime;
      _events.removeWhere((e) => e.eventElapsed);
      _events.sort((a, b) => a.durationFromStart.compareTo(b.durationFromStart));
      for (var event in _events.toList()) {
        if (event.durationFromStart <= currentTime) {
          if (eventCallback != null) {
            eventCallback!(currentTime, event);
          }
          event.processEvent(currentTime);
        }
      }
      if (currentTime - lastEventTime >= tickDuration) {
        if (tickCallback != null) {
          tickCallback!(currentTime);
        }
        lastEventTime = currentTime;
      }
      if (currentTime >= timerDuration) {
        stop();
      }
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  void addEvent(TimerEvents event) {
    event.timer = this;
    _events.add(event);
  }

  void removeEvent(TimerEvents event) {
    _events.remove(event);
  }
}
