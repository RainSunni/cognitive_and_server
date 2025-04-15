import 'dart:async';
import 'dart:math';

import 'package:cognitive_training/functions/generate_math_expression.dart';
import 'package:cognitive_training/pages/training_series/training_series_controller.dart';
import 'package:cognitive_training/widgets/metronome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/dialog/show_nsg_dialog.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../model/data_controller.dart';
import '../../model/training.dart';
import '../training/training_controller.dart';
import '../training_color/training_color_controller.dart';

enum TrainingScreenMode { countDown, training, pause }

class TrainingSeriesScreenPageOld extends StatefulWidget {
  const TrainingSeriesScreenPageOld({super.key});

  @override
  State<TrainingSeriesScreenPageOld> createState() => _TrainingSeriesScreenPageOldState();
}

class _TrainingSeriesScreenPageOldState extends State<TrainingSeriesScreenPageOld> with TickerProviderStateMixin {
  double voiceDelay = .2;
  var dataC = Get.find<DataController>();
  var colorC = Get.find<TrainingColorController>();
  late Metronome metronome;
  Color currentColor = Colors.white;
  String currentExpression = '';
  Timer? timer;
  Duration timeDuration = Duration.zero;
  DateTime timeStart = DateTime(0);
  late List<Color> colors;
  late AnimationController controller;
  late Animation<double> animation;
  var trainSeriesC = Get.find<TrainingSeriesController>();
  TrainingScreenMode trainingScreenMode = TrainingScreenMode.countDown;

  Training currentTraining = Training();
  int seriesCount = 0;
  int trainingCount = 0;

  @override
  void initState() {
    super.initState();

    if (Get.find<TrainingController>().trainingSeries == true) {
      seriesCount = trainSeriesC.currentItem.table.rows.length - 1;
    } else {
      seriesCount = 0;
    }

    // To keep the screen on:
    WakelockPlus.toggle(enable: true);
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..forward()
      ..addListener(() {
        if (controller.isCompleted) {
          controller.repeat();
        }
      });
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    // MetronomeMode mode = MetronomeMode.linear;
    // if (currentTraining.metronom.intervalProcent != 0) {
    //   mode = MetronomeMode.percentage;
    // }

    _timerPrepare();
  }

  play(String sound) {
    dataC.playSound(sound);
  }

  @override
  void dispose() {
    if (currentTraining.metronom.isNotEmpty) {
      metronome.stop();
    }
    timer!.cancel();
    controller.dispose();
    // To let the screen turn off again:
    WakelockPlus.toggle(enable: false);
    super.dispose();
  }

/* ------------------------------------------------------------------ Подготовка ------------------------------------------------------------------ */
  _timerPrepare() {
    trainingScreenMode = TrainingScreenMode.countDown;
    if (Get.find<TrainingController>().trainingSeries == true) {
      currentTraining = trainSeriesC.currentItem.table.rows[trainingCount].training;
    } else {
      currentTraining = Get.find<TrainingController>().currentItem;
    }
    if (currentTraining.colors.isNotEmpty) {
      colors = currentTraining.colors.colors.split(',').map((e) => stringToColor(e)).toList();
    } else {
      colors = [Colors.black];
    }
    if (currentTraining.metronom.isNotEmpty) {
      metronome = Metronome(currentTraining.metronom.metronomeMode,
          startBpm: currentTraining.metronom.initialBpm.toDouble(),
          endBpm: currentTraining.metronom.targetBpm.toDouble(),
          changePercent: currentTraining.metronom.intervalProcent / 100,
          delayTime: currentTraining.metronom.delayTime,
          duration: currentTraining.useDurationMinutes ? currentTraining.durationMinutes * 60 : currentTraining.durationSeconds, onBeat: (bpm) {
        if (!mounted) return metronome.stop();
      });
    }
    bool sayThree = false;
    bool sayTwo = false;
    bool sayOne = false;
    bool sayStart = false;
    _timer(
      duration: Duration(milliseconds: ((currentTraining.audioCountdownToStart + voiceDelay) * 1000).toInt()),
      onUpdate: (dur) {
        /// Голос 3 2 1

        if (!sayThree && dur < Duration(milliseconds: ((3 + voiceDelay) * 1000).toInt())) {
          sayThree = true;
          play('count3');
        } else if (!sayTwo && dur < Duration(milliseconds: ((2 + voiceDelay) * 1000).toInt())) {
          sayTwo = true;
          play('count2');
        } else if (!sayOne && dur < Duration(milliseconds: ((1 + voiceDelay) * 1000).toInt())) {
          sayOne = true;
          play('count1');
        } else if (!sayStart && dur < Duration(milliseconds: ((0 + voiceDelay) * 1000).toInt())) {
          sayStart = true;
          play('start');
        }
      },
      onFinish: () {
        // Голос Старт
        _timerStart();
      },
    );
  }

/* ------------------------------------------------------------------ Упражнение ------------------------------------------------------------------ */
  _timerStart() {
    trainingScreenMode = TrainingScreenMode.training;
    double timeTask = 0;
    double timeBeep = 0;
    var taskDuration = currentTraining.durationMinutes * 60 + currentTraining.durationSeconds;
    if (currentTraining.taskDelayTime != 0) {
      timeTask = (taskDuration - currentTraining.taskDelayTime) * 1000;
    }
    if (currentTraining.beeperInterval != 0) {
      timeBeep = (taskDuration - currentTraining.beeperInterval) * 1000 + 300;
    }
    _timer(
      duration: Duration(seconds: currentTraining.useDurationMinutes ? currentTraining.durationMinutes * 60 : currentTraining.durationSeconds),
      onUpdate: (dur) {
        var curMilliseconds = dur.inMilliseconds;
        if (currentTraining.audioCountdownToFinish != 0 && dur == Duration(seconds: currentTraining.audioCountdownToFinish)) {
          play('beeplong');
        }
        if (curMilliseconds < timeBeep) {
          play('beep');
          timeBeep = timeBeep - currentTraining.beeperInterval.toDouble() * 1000;
        }
        if (curMilliseconds < timeTask) {
          if (currentTraining.colors.isNotEmpty) {
            _changeBackgroundColor();
          }
          if (currentTraining.math.isNotEmpty) {
            _changeExpression();
          }
          timeTask -= currentTraining.taskDelayTime * 1000;
        }
      },
      onFinish: () {
        if (trainingCount == seriesCount) {
          timer!.cancel();
          if (currentTraining.metronom.isNotEmpty) {
            metronome.stop();
          }
          showNsgDialog(
            title: 'Упражнение завершено',
            text: 'Нажмите ОК для выхода',
            context: context,
            showCancelButton: false,
            buttons: [
              NsgButton(
                text: 'ОК',
                onPressed: () {
                  NsgNavigator.pop();
                },
              )
            ],
          );
        } else {
          if (currentTraining.metronom.isNotEmpty) {
            metronome.stop();
          }
          trainingScreenMode = TrainingScreenMode.pause;
          _timerPauseDelay();
        }
      },
    );
  }

  _timerPauseDelay() {
    _timer(
      duration: Duration(seconds: trainSeriesC.currentItem.table.rows[trainingCount].pauseSeconds),
      onUpdate: (dur) {},
      onFinish: () {
        trainingCount++;
        _timerPrepare();
      },
    );
  }

/* ---------------------------------------------------------------- Функция таймера --------------------------------------------------------------- */
  var initialTime = DateTime.now();
  var prevDuration = 0;
  Function(Duration)? _onUpdate;
  VoidCallback? _onFinish;
  _timer({required Duration duration, required Function(Duration) onUpdate, required VoidCallback onFinish}) {
    timeDuration = duration;
    _onUpdate = onUpdate;
    _onFinish = onFinish;
    if (timer != null) {
      timer!.cancel();
    }
    initialTime = DateTime.now();
    prevDuration = 0;
    //Предыдущее прошедшее время в миллисекундах

    timer = Timer(const Duration(milliseconds: 25), _timerFunc);
  }

  void _timerFunc() {
    //_changeBackgroundColor();
    var curTime = DateTime.now();
    var curMsTime = curTime.difference(initialTime).inMilliseconds;
    var delta = curMsTime - prevDuration;
    if (currentTraining.metronom.isNotEmpty) {
      metronome.checkMetronomeTimer(curMsTime);
    }
    //Если прошло меньше 100 просто ждем
    var needUpdate = false;
    while (delta >= 100) {
      needUpdate = true;
      timeDuration = timeDuration - 100.milliseconds;
      prevDuration += 100;
      delta -= 100;
      try {
        _onUpdate!(timeDuration);
      } catch (e) {
        debugPrint(e.toString());
      }
      if (timeDuration <= Duration.zero) {
        timer!.cancel();
        _onFinish!();
        return;
      }
    }
    if (needUpdate) {
      setState(() {});
    }
    timer = Timer(const Duration(milliseconds: 25), _timerFunc);
  }

  void _changeBackgroundColor() {
    if (!mounted) return;
    setState(() {
      List<Color> availableColors = colors.where((color) => color != currentColor).toList();
      if (availableColors.isNotEmpty) {
        currentColor = availableColors[Random().nextInt(availableColors.length)];
      } else {
        currentColor = colors[Random().nextInt(colors.length)];
      }
    });
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
                          if (trainingScreenMode == TrainingScreenMode.countDown)
                            Row(
                              children: [
                                Expanded(
                                    child: ScaleTransition(
                                  scale: animation,
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
                                    child: FittedBox(
                                        child:
                                            Text(_printDuration(timeDuration), style: TextStyle(color: textcolor, fontSize: 40, fontWeight: FontWeight.bold))),
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
}
