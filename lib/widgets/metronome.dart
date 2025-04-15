import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';

import '../model/data_controller.dart';
import '../model/enums/e_metronome_mode.dart';

class Metronome {
  EMetronomeMode mode;
  double startBpm;
  double currentBpm = 0;
  int duration;
  double endBpm;
  double changePercent;
  void Function(double currentBpm)? _beatCallback;
  bool isFinish = false;
  var dataC = Get.find<DataController>();
  //время следующей сработки в мс
  int triggerTime = 0;

  Metronome(
    this.mode, {
    required this.startBpm,
    required this.endBpm,
    required this.duration,
    int? delayTime,
    required this.changePercent,
    void Function(double currentBpm)? onBeat,
  }) {
    if (mode == EMetronomeMode.normal && startBpm != 0) {
      startBpm = startBpm;
      endBpm = double.maxFinite;
    } else if (mode == EMetronomeMode.linear && startBpm != 0 && endBpm != 0) {
      startBpm = startBpm;
      endBpm = endBpm;
    } else if (mode == EMetronomeMode.percentage && startBpm != 0 && changePercent != 0 && delayTime != 0) {
      startBpm = startBpm;
      changePercent = changePercent;
      endBpm = double.maxFinite;
    } else {
      throw Error();
    }
    currentBpm = startBpm;
    if (currentBpm == 0) {
      currentBpm = 1;
    }
    _beatCallback = onBeat;
    //triggerTime = duration * 1000 - (60000 ~/ currentBpm);
    triggerTime = (60000 ~/ currentBpm);
  }

  Future checkMetronomeTimer(int curDuration) async {
    if (triggerTime > curDuration) return;
    if (_beatCallback != null) _beatCallback!(currentBpm);
    // player.addToQueue(const Duration(milliseconds: 0));

    dataC.playSound('metronome');
    if (mode == EMetronomeMode.linear) {
      double diff = endBpm - startBpm;
      double changePerSecond = diff / duration;
      if ((changePerSecond > 0 && currentBpm < endBpm) || (changePerSecond < 0 && currentBpm > endBpm)) {
        currentBpm += changePerSecond;
      }
    } else if (mode == EMetronomeMode.percentage) {
      double changePerSecond = (currentBpm * changePercent);
      currentBpm += changePerSecond;
    }
    //await Future.delayed(Duration(milliseconds: 60000 ~/ currentBpm.ceil()));
    if (!(currentBpm < min(startBpm, (endBpm)) || currentBpm > max(startBpm, (endBpm))) && !isFinish) {
      triggerTime += 60000 ~/ currentBpm;
    }
  }

  void stop() {
    isFinish = true;
  }
}

// class MultiplePlayer {
//   MultiplePlayer(this.source);
//   final Source source;
//   Queue<DelayedPlayer> playersList = Queue<DelayedPlayer>();
//   bool queueIsReady = true;

//   String addToQueue(Duration interval) {
//     var key = Guid.newGuid();
//     playersList.addLast(DelayedPlayer(interval: interval, player: AudioPlayer(), playerKey: key));
//     startQueue();
//     return key;
//   }

//   void startQueue() {
//     if (queueIsReady) {
//       playFromQueue();
//     }
//   }

//   void playFromQueue() async {
//     queueIsReady = false;
//     if (playersList.isNotEmpty) {
//       var current = playersList.removeFirst();
//       await Future.delayed(current.interval);
//       await current.player.play(source);
//       current.player.dispose();
//       playFromQueue();
//     } else {
//       queueIsReady = true;
//     }
//   }

//   void cancel() {
//     playersList.clear();
//   }
// }

// class DelayedPlayer {
//   DelayedPlayer({required this.interval, required this.player, String? playerKey}) : key = playerKey ?? Guid.newGuid();

//   final Duration interval;
//   final AudioPlayer player;
//   final String key;
// }

// class MetronomeSound {
//   late double _currentBpm;
//   late double _targetBpm;
//   late double _bpmChangePerSecond;
//   late AudioPlayer _audioPlayer;
//   Timer? _timer;
//   void Function(int bpm)? onChange;
//   bool stopOnEnd;

//   MetronomeSound(int initialBpm, int targetBpm, int timeInSeconds,
//       {this.onChange, this.stopOnEnd = false) {
//     _currentBpm = initialBpm.toDouble();
//     _targetBpm = targetBpm.toDouble();
//     _bpmChangePerSecond = (targetBpm - initialBpm) / timeInSeconds;
//     _audioPlayer = AudioPlayer();
//   }

//   void start() {
//     if (_timer != null && _timer!.isActive) {
//       _timer!.cancel();
//     }

//     _timer = Timer.periodic(const Duration(seconds: 1), _updateBpm);
//   }

//   void _updateBpm(Timer timer) {
//     if ((_bpmChangePerSecond > 0 && _currentBpm < _targetBpm) ||
//         (_bpmChangePerSecond < 0 && _currentBpm > _targetBpm)) {
//       _currentBpm += _bpmChangePerSecond;
//       onChange!(_currentBpm.toInt());
//       _playSound();
//       timer.cancel();
//       timer = Timer.periodic(
//           Duration(milliseconds: (60000 / _currentBpm).toInt()), _updateBpm);
//     } else if (stopOnEnd) {
//       stop();
//     }
//   }

//   void _playSound() async {
//     _audioPlayer.play(
//         UrlSource('https://cdn.freesound.org/previews/46/46566_394391-lq.mp3'));
//   }

//   void stop() {
//     _timer?.cancel();
//   }
// }
