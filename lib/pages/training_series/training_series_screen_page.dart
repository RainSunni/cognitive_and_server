import 'dart:math';

import 'package:cognitive_training/functions/generate_math_expression.dart';
import 'package:cognitive_training/model/enums.dart';
import 'package:cognitive_training/model/training_metronom.dart';
import 'package:cognitive_training/pages/training_series/metronom_event.dart';
import 'package:cognitive_training/pages/training_series/training_event.dart';
import 'package:cognitive_training/pages/training_series/training_series_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/dialog/show_nsg_dialog.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../model/data_controller.dart';
import '../../model/training.dart';
import '../training/training_controller.dart';
import '../training_color/training_color_controller.dart';
import 'countdown_event.dart';
import 'nsg_timer.dart';

enum TrainingScreenMode { countDown, training, pause, finish }

class TrainingSeriesScreenPage extends StatefulWidget {
  const TrainingSeriesScreenPage({super.key});

  @override
  State<TrainingSeriesScreenPage> createState() => _TrainingSeriesScreenPageState();
}

class _TrainingSeriesScreenPageState extends State<TrainingSeriesScreenPage> with TickerProviderStateMixin {
  //Задержка воспроизведения звука в мс. Т.е. все звуки воспроизводим с этим опережением,
  int voiceDelay = 300;
  var dataC = Get.find<DataController>();
  var colorC = Get.find<TrainingColorController>();
  var rnd = Random();

  ///Текущий цвет фона. При смене цвета может быть на время перехода заменен на черный, тогда
  ///следующий цвет, когторый станет текущим сохраняется в nextColor
  Color currentColor = Colors.white;

  ///Следующий цвет, который станет текущим через colorChangeDelay мс
  Color nextColor = Colors.black;

  ///Задержка смены цветов. На время нее вместо следующего увета используется черный цвет
  int colorChangeDelay = 150;
  String currentExpression = '';

  ///Оставшееся время упражнения - отображается в процессе выполнения упражнения
  Duration timeDuration = Duration.zero;
  //Текст выводимый в процессе обратного отсчета
  String countdownText = '';
  DateTime timeStart = DateTime(0);
  late List<Color> colors;
  late AnimationController animationController;
  late Animation<double> animation;
  var trainSeriesC = Get.find<TrainingSeriesController>();
  var trainingScreenMode = TrainingScreenMode.countDown;

  Training currentTraining = Training();
  int seriesCount = 0;
  int trainingCount = 0;

  @override
  void initState() {
    super.initState();
    startExercise();
  }

  play(String sound) {
    dataC.playSound(sound);
  }

  void startExercise() {
    if (Get.find<TrainingController>().trainingSeries == true) {
      seriesCount = trainSeriesC.currentItem.table.rows.length - 1;
    } else {
      seriesCount = 0;
    }

    // To keep the screen on:
    WakelockPlus.toggle(enable: true);
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    // ..forward()
    // ..addListener(() {
    //   // if (animationController.isCompleted) {
    //   //   animationController.repeat();
    //   // }
    // });
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeIn);
    _timerPrepare();
  }

  @override
  void dispose() {
    mainTimer.stop();
    timerPrepare.stop();
    relaxTimer.stop();
    animationController.dispose();
    // To let the screen turn off again:
    WakelockPlus.toggle(enable: false);
    super.dispose();
  }

/* ------------------------------------------------------------------ Подготовка ------------------------------------------------------------------ */
  Future _timerPrepare() async {
    trainingScreenMode = TrainingScreenMode.pause;
    // play('beeplong');
    // await Future.delayed(const Duration(seconds: 1));

    trainingScreenMode = TrainingScreenMode.countDown;
    if (Get.find<TrainingController>().trainingSeries) {
      if (trainSeriesC.currentItem.table.length <= trainingCount) {
        Get.back();
        return;
      }
      currentTraining = trainSeriesC.currentItem.table.rows[trainingCount].training;
    } else {
      currentTraining = Get.find<TrainingController>().currentItem;
    }
    if (currentTraining.colors.isNotEmpty) {
      colors = currentTraining.colors.colors.split(',').map((e) => stringToColor(e)).toList();
    } else {
      colors = [Colors.black];
    }

    //Задаем столько цифр, сколько длительность подготовки
    var timerDuration = ((currentTraining.audioCountdownToStart) * 1000 + voiceDelay).toInt();
    var eventsList = geterateVoiceCountdown(timerDuration, currentTraining.audioCountdownToStart + 1);

    // eventsList.addAll(eventsList)
    var timerPrepare = NsgTimer(
        timerDuration: timerDuration + 1000,
        tickCallback: (dur) {},
        eventCallback: (timeFromStart, event) {
          if (event is CountdownEvents) {
            countdownText = event.text;
          }
          animationController.repeat();
          // setState(() {});
        },
        events: eventsList,
        //После окончания подготовительного этапа, запускаем основной
        stopCallback: _timerStart);
    timerPrepare.start();
  }

/* ------------------------------------------------------------------ Упражнение ------------------------------------------------------------------ */
  NsgTimer mainTimer = NsgTimer(timerDuration: 0, tickCallback: (timeFromStart) {}, stopCallback: () {});
  NsgTimer timerPrepare = NsgTimer(timerDuration: 0, tickCallback: (timeFromStart) {}, stopCallback: () {});
  NsgTimer relaxTimer = NsgTimer(timerDuration: 0, tickCallback: (timeFromStart) {}, stopCallback: () {});
  var needToPlayAudioCountdownToFinish = false;
  void _timerStart() {
    trainingScreenMode = TrainingScreenMode.training;
    countdownText = '';
    var timerDuration = (currentTraining.useDurationMinutes ? currentTraining.durationMinutes * 60 : currentTraining.durationSeconds) * 1000;
    var eventList = <TimerEvents>[];

    //Устанавливаем флажок, чтобы установка цвета фона происходила не через черный цвет первый раз
    firstTimeSetBackgroundColor = true;
    //Смена цветового и числового заданий
    if (currentTraining.taskDelayTime != 0) {
      eventList.add(TimerEvents(
          durationFromStart: 0,
          callback: (duration, eventData) {
            if (currentTraining.colors.isNotEmpty) {
              _changeBackgroundColor();
              //При смене цветов, проводим смену через черный цвет, чтобы было видно изменения цвета
              //Создаем событие на замену черного цвета на новый цвет фона
              mainTimer.addEvent(TimerEvents(
                  durationFromStart: duration + colorChangeDelay,
                  callback: (duration, eventData) {
                    setState(() {
                      currentColor = nextColor;
                    });
                  },
                  repeatCount: 0,
                  repeatInterval: 0));
            }
            if (currentTraining.math.isNotEmpty) {
              _changeExpression();
            }
          },
          repeatCount: 1000000,
          repeatInterval: currentTraining.taskDelayTime * 1000));
    }
    //Добавляем переодический сигнал
    if (currentTraining.beeperInterval != 0) {
      eventList.add(TimerEvents(
          durationFromStart: currentTraining.beeperInterval * 1000 - voiceDelay,
          soundName: 'beep',
          repeatCount: 1000000,
          repeatInterval: currentTraining.beeperInterval * 1000));
    }
    //Добавляем короткие сигналы об окончании упражнения (за заданное кол-во секунд) и длинный сигнал при завершении
    if (currentTraining.audioCountdownToFinish != 0) {
      var beepsBeforeFinishEvents = getBeepsBeforeFinishEvents(timerDuration);
      eventList.addAll(beepsBeforeFinishEvents);
    }
    //Добавляем события мотронома
    var metronomEvents = getMetronomEvents(timerDuration, currentTraining.metronom);
    eventList.addAll(metronomEvents);

    needToPlayAudioCountdownToFinish = currentTraining.audioCountdownToFinish != 0;

    mainTimer = NsgTimer(
        timerDuration: timerDuration,
        tickCallback: (dur) {
          timeDuration = Duration(milliseconds: timerDuration - dur);
          if (mainTimer.isStarted && mounted) {
            setState(() {});
          }
        },
        stopCallback: () {
          _timerPauseDelay();
        },
        eventCallback: (timeFromStart, event) {
          if (event is MetronomEvents) {
            event.calcNextInterval(currentTraining, timeFromStart);
          }
        },
        tickDuration: 25,
        events: eventList);
    if (mounted) {
      setState(() {});
    }
    mainTimer.start();
  }

  ///Включить таймер отдаха между упражнениями
  _timerPauseDelay() async {
    trainingScreenMode = TrainingScreenMode.pause;
    //Если это одиночное упражнение (не серия), заканчиваем выполнение, возвращаемся в список упражнений
    if (!Get.find<TrainingController>().trainingSeries) {
      trainingScreenMode = TrainingScreenMode.finish;
      currentColor = Colors.white;
      setState(() {});
      //Непонятно зачем эта пауза
      //Future.delayed(const Duration(seconds: 3)).then((value) => Get.back());
      return;
    }
    //Если это последнее упражнение в серии, заканчиваем тренеровку
    if (trainSeriesC.currentItem.table.length <= trainingCount) {
      Get.back();
      return;
    }
    var pauseDuration = trainSeriesC.currentItem.table.rows[trainingCount].pauseSeconds * 1000;
    relaxTimer = NsgTimer(
      timerDuration: trainSeriesC.currentItem.table.rows[trainingCount].pauseSeconds * 1000,
      tickCallback: (dur) {
        timeDuration = Duration(milliseconds: pauseDuration - dur);
        if (relaxTimer.isStarted && mounted) {
          setState(() {});
        }
      },
      stopCallback: () {
        trainingCount++;
        _timerPrepare();
      },
      tickDuration: 25,
    );
    relaxTimer.start();
  }

/* ---------------------------------------------------------------- Функция таймера --------------------------------------------------------------- */
  var prevEventTime = 0.0;

  ///При значении установленном в true, установка цвета фона происходит без перехода через черный экран
  bool firstTimeSetBackgroundColor = true;

  void _changeBackgroundColor() {
    if (!mounted) return;
    var color = Colors.black;
    List<Color> availableColors = colors; //.where((color) => color != currentColor).toList();
    if (availableColors.isNotEmpty) {
      var i = rnd.nextInt(availableColors.length);
      color = availableColors[i];
    } else {
      color = colors[rnd.nextInt(colors.length)];
    }
    nextColor = color;
    if (firstTimeSetBackgroundColor) {
      firstTimeSetBackgroundColor = false;
      currentColor = color;
    } else {
      currentColor = Colors.black;
    }
    setState(() {});
  }

  void _changeExpression() {
    if (!mounted) return;
    setState(() {
      currentExpression = generateMathExpression(currentTraining.math.minNumber, currentTraining.math.maxNumber,
          useAddition: currentTraining.math.useAddition,
          useSubtraction: currentTraining.math.useSubtraction,
          useMultiplication: currentTraining.math.useMultiplication);
    });
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigits2(int n) => n.toString().padLeft(4, "0")[1];
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds = twoDigits2(duration.inMilliseconds.remainder(1000));

    if (trainingScreenMode == TrainingScreenMode.countDown || trainingScreenMode == TrainingScreenMode.pause) {
      return (duration.inSeconds + 1).remainder(60).toString();
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds:$twoDigitMilliseconds";
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textcolor = calculateTextColor(currentColor);

    return GestureDetector(
      onTap: () {
        showNsgDialog(
          title: 'Идёт серия упражнений',
          text: 'Вы уверены, что хотите прервать выполняемую серию упражнений?',
          context: context,
          onConfirm: () {
            timerPrepare.stop();
            mainTimer.stop();
            relaxTimer.stop();
            Navigator.pop(context);
          },
        );
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: currentColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (trainingScreenMode == TrainingScreenMode.finish)
                            Center(
                              child: Column(children: [
                                Text(
                                  'Упражнение завершено',
                                  style: TextStyle(color: textcolor, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                NsgButton(
                                    width: 150,
                                    text: 'ВЫЙТИ',
                                    backColor: Colors.red,
                                    onPressed: () {
                                      timerPrepare.stop();
                                      mainTimer.stop();
                                      relaxTimer.stop();
                                      Navigator.pop(context);
                                    }),
                                const SizedBox(
                                  height: 30,
                                ),
                                NsgButton(
                                  width: 150,
                                  text: 'ПОВТОРИТЬ',
                                  onPressed: () {
                                    startExercise();
                                  },
                                )
                              ]),
                            ),
                          if (trainingScreenMode == TrainingScreenMode.training)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (currentTraining.colors.isEmpty && currentTraining.math.isEmpty)
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: FittedBox(
                                                child: Text(
                                                  _printDuration(timeDuration),
                                                  style: TextStyle(color: textcolor, fontSize: 100, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (currentExpression.isNotEmpty)
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: FittedBox(
                                                child: Text(
                                                  currentExpression,
                                                  style: TextStyle(color: textcolor, fontSize: 100, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          if (trainingScreenMode == TrainingScreenMode.countDown) const Text('Обратный отсчёт'),
                          if (trainingScreenMode == TrainingScreenMode.training) const Text('Тренировка'),
                          if (trainingScreenMode == TrainingScreenMode.pause) const Text('Пауза между тренировками'),
                          if (trainingScreenMode == TrainingScreenMode.pause)
                            Text(_printDuration(timeDuration), style: TextStyle(color: textcolor, fontSize: 40, fontWeight: FontWeight.bold)),
                          if (trainingScreenMode == TrainingScreenMode.training)
                            (currentTraining.colors.isEmpty && currentTraining.math.isEmpty)
                                ? const SizedBox()
                                : Text(_printDuration(timeDuration), style: TextStyle(color: textcolor, fontSize: 40, fontWeight: FontWeight.bold)),
                          if (trainingScreenMode == TrainingScreenMode.countDown && countdownText.isNotEmpty)
                            Row(
                              children: [
                                Expanded(
                                    child: ScaleTransition(
                                  scale: animation,
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
                                    child: FittedBox(child: Text(countdownText, style: TextStyle(color: textcolor, fontSize: 40, fontWeight: FontWeight.bold))),
                                  ),
                                )),
                              ],
                            ),
                          if (trainingScreenMode == TrainingScreenMode.training)
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        FractionallySizedBox(
                                          widthFactor: progress(),
                                          child: Container(
                                            margin: const EdgeInsets.all(3),
                                            height: 10,
                                            decoration: BoxDecoration(color: textcolor.withAlpha(127)),
                                          ),
                                        ),
                                        Container(
                                          height: 16,
                                          decoration: BoxDecoration(color: textcolor.withAlpha(75)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double progress() {
    double result = timeDuration.inSeconds / (currentTraining.useDurationMinutes ? currentTraining.durationMinutes * 60 : currentTraining.durationSeconds);
    return result;
  }

  ///Генерация голосовых оповещений обратного отсчета
  List<TimerEvents> geterateVoiceCountdown(int timerDuration, int seconds) {
    var list = <TimerEvents>[];

    //1. Добавляем сигналы обратного отсчета от 10 до 1 и обновление экрана каждую секунду
    for (var i = 0; i < seconds; i++) {
      if (i <= 10 && i > 0) {
        //Голосовое сообщение
        list.add(CountdownEvents(durationFromStart: timerDuration - i * 1000 - voiceDelay, soundName: 'count$i', text: i.toString()));
      }
      //Обновление экрана
      list.add(TimerEvents(durationFromStart: timerDuration - i * 1000, callback: (dur, eventData) => setState(() {})));
    }
    //Добавляем голосовую команду "Старт"
    list.add(CountdownEvents(durationFromStart: timerDuration - voiceDelay, soundName: 'start', text: 'СТАРТ', isStart: true));
    return list;
  }

  List<TimerEvents> getMetronomEvents(int timerDuration, TrainingMetronom metronom) {
    var events = <MetronomEvents>[];
    if (metronom.isNotEmpty) {
      if (metronom.metronomeMode == EMetronomeMode.normal) {
        var interval = 60 * 1000 ~/ (metronom.initialBpm == 0 ? 1 : metronom.initialBpm);
        events.add(MetronomEvents(durationFromStart: interval, soundName: 'metronome', metronom: metronom, repeatCount: 1000000, repeatInterval: interval));
      } else if (metronom.metronomeMode == EMetronomeMode.linear) {
        var interval = 60 * 1000 ~/ (metronom.initialBpm == 0 ? 1 : metronom.initialBpm);
        events.add(MetronomEvents(durationFromStart: interval, soundName: 'metronome', metronom: metronom));
      } else if (metronom.metronomeMode == EMetronomeMode.percentage) {
        var interval = 60 * 1000 ~/ (metronom.initialBpm == 0 ? 1 : metronom.initialBpm);
        events.add(MetronomEvents(durationFromStart: interval, soundName: 'metronome', metronom: metronom));
      }
    }
    return events;
  }

  List<TimerEvents> getBeepsBeforeFinishEvents(int timerDuration) {
    var events = <TimerEvents>[];
    for (var i = 1; i <= currentTraining.audioCountdownToFinish; i++) {
      events.add(TimerEvents(durationFromStart: timerDuration - i * 1000 - voiceDelay, soundName: 'beep'));
    }
    events.add(TimerEvents(durationFromStart: timerDuration - voiceDelay, soundName: 'beeplong'));
    return events;
  }
}
