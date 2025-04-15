import 'package:cognitive_training/model/enums.dart';
import 'package:cognitive_training/pages/training_series/training_event.dart';
import 'package:flutter/material.dart';

import '../../model/data_controller_model.dart';

///Себытия таймера - метроном
class MetronomEvents extends TimerEvents {
  TrainingMetronom metronom;

  ///Время смены частоты метронома - для режима "Процент"
  int changeBpmTime = 0;

  ///Текущая частота метронома - для режима "Процент"
  double currentBpm = 0;

  MetronomEvents(
      {required super.durationFromStart,
      super.repeatCount = 0,
      super.repeatInterval = 0,
      super.soundName = '',
      super.callback,
      super.eventData,
      required this.metronom}) {
    if (metronom.metronomeMode == EMetronomeMode.percentage) {
      changeBpmTime = metronom.delayTime * 1000;
      currentBpm = metronom.initialBpm.toDouble();
    }
  }

  ///Функция расчета текущей частоты ритма
  void calcNextInterval(
    Training training,
    int dur,
  ) {
    if (timer == null) return;
    if (metronom.metronomeMode == EMetronomeMode.linear) {
      var initialBpm = metronom.initialBpm == 0 ? 1 : metronom.initialBpm;
      var targetBpm = metronom.targetBpm == 0 ? 1 : metronom.targetBpm;
      var bpm = (targetBpm - initialBpm) / timer!.timerDuration * dur + initialBpm;
      var interval = 60 * 1000 ~/ bpm;
      if (timer != null) {
        timer!.addEvent(MetronomEvents(durationFromStart: dur + interval, soundName: soundName, metronom: metronom));
      }
    }
    if (metronom.metronomeMode == EMetronomeMode.percentage) {
      if (dur > changeBpmTime) {
        currentBpm = currentBpm * (100 + metronom.intervalProcent) / 100;
        changeBpmTime += metronom.delayTime * 1000;
      }
      debugPrint('BPM = $currentBpm');
      var interval = 60 * 1000 ~/ currentBpm;
      if (timer != null) {
        timer!.addEvent(MetronomEvents(durationFromStart: dur + interval, soundName: soundName, metronom: metronom)
          ..currentBpm = currentBpm
          ..changeBpmTime = changeBpmTime);
      }
    }
  }
}
