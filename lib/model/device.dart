import 'dart:async';

import 'package:cognitive_training/pages/device/device_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'generated/device.g.dart';

class Device extends DeviceGenerated {
  //Время видрации, в течении которого не фиксируем повторную вибрацию, мс
  int vibrationTime = 300;
  bool isVibrationDetectorOn = false;
  DateTime lastVibrationTime = DateTime(0);

  bool isVibrationDetected = false;

  ///Проверяем не пора ли убрать признак срабатывания датчика удара
  ///Пока он проставлен, игнорируем повторные срабатывания
  ///Время задержки до следующего срабатывания датчика опредоляеться vibrationTime
  void _chechVibration() {
    if (isVibrationDetected) {
      var diff = DateTime.now().difference(lastVibrationTime).inMilliseconds;
      if (diff >= vibrationTime) {
        //Время вибрации прошло, снимаем флажок, обновляем экран
        isVibrationDetected = false;
        Get.find<DeviceController>().sendNotify();
        return;
      }
      Timer(Duration(milliseconds: diff + 10), _chechVibration);
    }
  }

  void vibrationDetected() {
    lastVibrationTime = DateTime.now();
    if (isVibrationDetected) {
      debugPrint('Игнорируем срабатывания датчика, т.к. еще не вышел таймаут');
      return;
    }

    isVibrationDetected = true;
    _chechVibration();
  }
}
