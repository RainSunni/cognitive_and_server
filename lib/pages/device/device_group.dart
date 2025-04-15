import 'dart:math';

import 'package:cognitive_training/pages/device/device_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/data_controller.dart';
import '../../model/device.dart';

class DeviceGroup {
  List<Device> items = [];
  var rnd = Random();
  bool goalStationMode = false;

  ///Обработка срабатывания датчика вибрации на устройстве
  Future vibrationDetected(Device device) async {
    //Временно провисал условние, которое всегда выполняется
    if (items.length < 30) {
      await randomLampAndDeviceSelection(device);
    } else {
      Get.find<DeviceController>().setRed(device, true);
    }
  }

  Device? lastDevice;
  DateTime lastChange = DateTime.now();
  Future randomLampAndDeviceSelection(Device device) async {
    if (lastDevice != null && lastDevice != device) return;
    if (DateTime.now().difference(lastChange).inMilliseconds < 1000) return;
    lastChange = DateTime.now();
    assert(items.isNotEmpty);
    var deviceController = Get.find<DeviceController>();
    var deviceArray = <Device>[];
    deviceArray.addAll(items);
    if (lastDevice != null) {
      deviceArray.remove(lastDevice);
    }
    device = deviceArray[rnd.nextInt(deviceArray.length)];
    lastDevice = device;
    var colorList = [Colors.red, Colors.green, Colors.blue];
    await Get.find<DataController>().playSound('beep');
    // if (device == items[i]) {
    //   if (device.isRedOn) {
    //     colorList.remove(Colors.red);
    //   }
    //   if (device.isGreenOn) {
    //     colorList.remove(Colors.green);
    //   }
    //   if (device.isBlueOn) {
    //     colorList.remove(Colors.blue);
    //   }
    //   if (colorList.isEmpty) {
    //     colorList = [Colors.red, Colors.green, Colors.blue];
    //   }
    // }
    //device = items[i];
    var onColor = colorList[rnd.nextInt(colorList.length)];
    for (var d in items) {
      if (d.isRedOn) {
        await deviceController.setRed(d, false);
      }
      if (d.isBlueOn) {
        await deviceController.setBlue(d, false);
      }
      if (d.isGreenOn) {
        await deviceController.setGreen(d, false);
      }
    }
    if (onColor == Colors.red) {
      await deviceController.setRed(device, true);
    }
    if (onColor == Colors.blue) {
      await deviceController.setBlue(device, true);
    }
    if (onColor == Colors.green) {
      await deviceController.setGreen(device, true);
    }
  }

  ///Добавление нового устройства в группу
  void addDevice(Device device) {
    if (items.firstWhereOrNull((e) => e.id == device.id) != null) return;
    items.add(device);
  }
}
