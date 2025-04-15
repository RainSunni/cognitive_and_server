import 'dart:async';
import 'dart:math';

import 'package:cognitive_training/functions/generate_math_expression.dart';
import 'package:cognitive_training/model/training.dart';
import 'package:cognitive_training/widgets/metronome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/dialog/show_nsg_dialog.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../model/data_controller.dart';
import '../training_color/training_color_controller.dart';

class TrainingScreenPage extends StatefulWidget {
  const TrainingScreenPage({super.key, required this.options});
  final Training options;

  @override
  State<TrainingScreenPage> createState() => _TrainingScreenPageState();
}

class _TrainingScreenPageState extends State<TrainingScreenPage> with TickerProviderStateMixin {
  double voiceDelay = .2;
  var dataC = Get.find<DataController>();
  var colorC = Get.find<TrainingColorController>();
  late Metronome metronome;
  Color currentColor = Colors.white;
  String currentExpression = '';
  Timer? timer;
  bool showProgress = false;
  Duration timeDuration = Duration.zero;
  DateTime timeStart = DateTime(0);
  late List<Color> colors;
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
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
    if (widget.options.colors.isNotEmpty) {
      colors = widget.options.colors.colors.split(',').map((e) => stringToColor(e)).toList();
    } else {
      colors = [Colors.black];
    }

    // MetronomeMode mode = MetronomeMode.linear;
    // if (widget.options.metronom.intervalProcent != 0) {
    //   mode = MetronomeMode.percentage;
    // }
    if (widget.options.metronom.isNotEmpty) {
      metronome = Metronome(widget.options.metronom.metronomeMode,
          startBpm: widget.options.metronom.initialBpm.toDouble(),
          endBpm: widget.options.metronom.targetBpm.toDouble(),
          changePercent: widget.options.metronom.intervalProcent / 100,
          delayTime: widget.options.metronom.delayTime,
          duration: widget.options.useDurationMinutes ? widget.options.durationMinutes * 60 : widget.options.durationSeconds, onBeat: (bpm) {
        if (!mounted) return metronome.stop();
      });
    }
    _timerPrepare();
  }

  play(String sound) {
    dataC.playSound(sound);
  }

  @override
  void dispose() {
    if (widget.options.metronom.isNotEmpty) {
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
    _timer(
      duration: Duration(milliseconds: ((widget.options.audioCountdownToStart + voiceDelay) * 1000).toInt()),
      onUpdate: (dur) {
/* --------------------------------------------------------------------- Голос 3 2 1 -------------------------------------------------------------------- */
        if (dur == Duration(milliseconds: ((3 + voiceDelay) * 1000).toInt())) {
          play('count3');
        } else if (dur == Duration(milliseconds: ((2 + voiceDelay) * 1000).toInt())) {
          play('count2');
        } else if (dur == Duration(milliseconds: ((1 + voiceDelay) * 1000).toInt())) {
          play('count1');
        } else if (dur == Duration(milliseconds: ((0 + voiceDelay) * 1000).toInt())) {
          play('start');
        }
      },
      onFinish: () {
/* --------------------------------------------------------------------- Голос Старт -------------------------------------------------------------------- */

        _timerStart();
      },
    );
  }

/* ------------------------------------------------------------------ Упражнение ------------------------------------------------------------------ */
  _timerStart() {
    showProgress = true;
    double timeTask = 0;
    double timeBeep = 0;
    var taskDuration = widget.options.durationMinutes * 60 + widget.options.durationSeconds;
    if (widget.options.taskDelayTime != 0) {
      timeTask = (taskDuration - widget.options.taskDelayTime) * 1000;
    }
    if (widget.options.beeperInterval != 0) {
      timeBeep = (taskDuration - widget.options.beeperInterval) * 1000 + 300;
    }
    _timer(
      duration: Duration(seconds: widget.options.useDurationMinutes ? widget.options.durationMinutes * 60 : widget.options.durationSeconds),
      onUpdate: (dur) {
        var curMilliseconds = dur.inMilliseconds;
        if (widget.options.audioCountdownToFinish != 0 && dur == Duration(seconds: widget.options.audioCountdownToFinish)) {
          play('beeplong');
        }
        if (curMilliseconds < timeBeep) {
          play('beep');
          timeBeep = timeBeep - widget.options.beeperInterval.toDouble() * 1000;
        }
        if (curMilliseconds < timeTask) {
          if (widget.options.colors.isNotEmpty) {
            _changeBackgroundColor();
          }
          if (widget.options.math.isNotEmpty) {
            _changeExpression();
          }
          timeTask -= widget.options.taskDelayTime * 1000;
        }
      },
      onFinish: () {
        timer!.cancel();
        if (widget.options.metronom.isNotEmpty) {
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
    if (widget.options.metronom.isNotEmpty) {
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
      currentExpression = generateMathExpression(widget.options.math.minNumber, widget.options.math.maxNumber,
          useAddition: widget.options.math.useAddition,
          useSubtraction: widget.options.math.useSubtraction,
          useMultiplication: widget.options.math.useMultiplication);
    });
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigits2(int n) => n.toString().padLeft(4, "0")[1];
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds = twoDigits2(duration.inMilliseconds.remainder(1000));

    if (!showProgress) {
      return (duration.inSeconds + 1).remainder(60).toString();
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds:$twoDigitMilliseconds";
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textcolor = calculateTextColor(currentColor);
    return Scaffold(
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
                        if (showProgress)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.options.colors.isEmpty && widget.options.math.isEmpty)
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
                        showProgress
                            ? (widget.options.colors.isEmpty && widget.options.math.isEmpty)
                                ? const SizedBox()
                                : Text(_printDuration(timeDuration), style: TextStyle(color: textcolor, fontSize: 40, fontWeight: FontWeight.bold))
                            : Row(
                                children: [
                                  Expanded(
                                      child: ScaleTransition(
                                    scale: animation,
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
                                      child: FittedBox(
                                          child: Text(_printDuration(timeDuration),
                                              style: TextStyle(color: textcolor, fontSize: 40, fontWeight: FontWeight.bold))),
                                    ),
                                  )),
                                ],
                              ),
                        !showProgress
                            ? const SizedBox()
                            : Row(
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
    );
  }

  double progress() {
    double result = timeDuration.inSeconds / (widget.options.useDurationMinutes ? widget.options.durationMinutes * 60 : widget.options.durationSeconds);
    return result;
  }
}
