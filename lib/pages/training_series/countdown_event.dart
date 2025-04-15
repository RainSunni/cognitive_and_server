import 'package:cognitive_training/pages/training_series/training_event.dart';

class CountdownEvents extends TimerEvents {
  String text;
  bool isStart;

  CountdownEvents(
      {required super.durationFromStart,
      super.repeatCount = 0,
      super.repeatInterval = 0,
      super.soundName = '',
      super.callback,
      super.eventData,
      this.text = '',
      this.isStart = false});
}
