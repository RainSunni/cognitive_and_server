import 'package:cognitive_training/model/data_controller.dart';
import 'package:get/get.dart';

import 'nsg_timer.dart';

///Класс событий, происходящих во время упражнения
class TimerEvents {
  ///Таймер по которому срабатывает событие
  NsgTimer? timer;

  ///Время события (от начала работы таймера, мс)
  int durationFromStart;

  ///Время события (от конца работы таймера, мс)
  set durationFromEnd(int value) {
    assert(timer != null, 'Задавать время от конца можно только после назначения таймера');
    assert(value <= timer!.timerDuration, 'Заданное время события больше длительности таймера');
    durationFromStart = timer!.timerDuration - value;
  }

  ///Количество повторов события. При каждом срабатывании вичитается единичка
  ///Если нужно установить неограниченное количество повторов, рекомендуем устанавливать параметр в значение int.MaxValue
  int repeatCount;

  ///Интервал срабатывания таймера
  int repeatInterval;

  ///Имя звука, воспроизводимого при возникновении времени события
  ///Если имя не задано, звук воспроизведен не будет
  String soundName;

  ///Событие отработано. В случае повторяющихся событий флаг будет выставлен после исполнения последнего повтора
  bool eventElapsed = false;

  dynamic eventData;

  ///Функция, вызываемая при срабатывании события. Аргументом передается текущее время от начала таймера
  Function(int duration, dynamic eventData)? callback;

  TimerEvents({required this.durationFromStart, this.repeatCount = 0, this.repeatInterval = 0, this.soundName = '', this.callback, this.eventData});

  ///Обработать событие. Если нужны дополнительные действия, можно перекрыть в классах-наследниках
  void processEvent(int duration) {
    //На всякий случай, если событие уже отработано, исключаем повторное срабатывание
    if (eventElapsed) {
      return;
    }
    if (soundName.isNotEmpty) {
      Get.find<DataController>().playSound(soundName);
    }
    if (callback != null) {
      callback!(duration, eventData);
    }
    if (repeatCount > 0 && repeatInterval > 0) {
      repeatCount--;
      durationFromStart += repeatInterval;
    } else {
      eventElapsed = true;
      if (timer != null) {
        timer!.removeEvent(this);
      }
    }
  }
}
