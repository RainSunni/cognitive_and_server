import 'dart:io';

import 'package:cognitive_training/helper.dart';
import 'package:cognitive_training/model/data_controller.dart';
import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:cognitive_training/pages/device/device_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:nsg_controls/helpers.dart';

class DeviceHttpApi {
  final String address;
  final int port;
  void Function(String params)? onReceive;
  HttpServer? _server;

  DeviceHttpApi({this.address = '192.168.1.31', this.port = 5900});

  Future<void> runServer() async {
    final info = NetworkInfo();
    var deviceController = Get.find<DeviceController>();
    if (Helper.isMobile || Platform.isMacOS) {
      deviceController.ipAddress = (await info.getWifiIP()) ?? '';
    } else {
      deviceController.ipAddress = '0.0.0.0';
    }
    debugPrint('address = ${deviceController.ipAddress}');
    deviceController.isWiFiDetected = deviceController.ipAddress.isNotEmpty;
    if (!deviceController.isWiFiDetected) return;
    deviceController.sendNotify();

    _server = await HttpServer.bind(deviceController.ipAddress, port);
    await for (final request in _server!) {
      if (request.method != 'GET') {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        return;
      }
      final uri = request.requestedUri;
      final segments = uri.pathSegments;

      if (segments.isEmpty) {
        request.response.statusCode = HttpStatus.badRequest;
      } else {
        if (onReceive != null) {
          onReceive!(segments.join('/'));
        }

        if (segments.isEmpty) {
          request.response.statusCode = HttpStatus.badRequest;
        }
        debugPrint(uri.toString());

        if (segments[0] == 'get-guid') {
          //Регистрация устройства
          _getGuid(segments, uri, deviceController, request);
        } else if (segments[0] == 'get_time') {
          //Регистрация устройства
          _getTime(segments, uri, deviceController, request);
        } else if (segments[0] == 'Vibration') {
          //Регистрация устройства
          _getVibration(segments, uri, deviceController, request);
        }

        await request.response.close();
      }
    }
  }

  //1. Регистрация устройства
  void _getGuid(List<String> segments, Uri uri, DeviceController deviceController, HttpRequest request) {
    //Регистрация устройства
    if (!uri.queryParameters.containsKey('guid')) {
      debugPrint('Нет идентификатора устройства');
    }
    var deviceId = uri.queryParameters['guid'] ?? '';
    if (deviceId.isEmpty) {
      debugPrint('Идентификатора устройства не задан');
    }
    //Регистрируем устройство в списке устройств

    var device = (deviceController.items.firstWhereOrNull((element) => element.id == deviceId)) ?? Device();
    if (device.isEmpty) {
      //Дабавляем новое устройство
      device.id = deviceId;
      device.address = request.connectionInfo!.remoteAddress.address;
      debugPrint('NEW DEVICE registered. id=$deviceId, ip=${device.address}');
      deviceController.items.add(device);
      deviceController.sendNotify();
    } else {
      //Дабавляем новое устройство
      device.id = deviceId;
      device.address = request.connectionInfo!.remoteAddress.address;
      debugPrint('EXISTED DEVICE ping. id=$deviceId, ip=${device.address}');
    }
    request.response.write('OK');
  }

  //Синхронизация времени
  void _getTime(List<String> segments, Uri uri, DeviceController deviceController, HttpRequest request) {
    if (segments[0] == 'get_time') {
      var sTime = DateTime.now().format('dd.MM.yyyy HH:mm:ss', 'ru');
      debugPrint('SYNC TIME. t=$sTime');
      request.response.write(sTime);
    }
  }

  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close();
    }
  }

  play(String sound) {
    Get.find<DataController>().playSound('beep');
  }

  Future _getVibration(List<String> segments, Uri uri, DeviceController deviceController, HttpRequest request) async {
    debugPrint('VIBRATION');

    var deviceController = Get.find<DeviceController>();
    var ip = request.connectionInfo!.remoteAddress.address;
    var device = deviceController.items.firstWhereOrNull((e) => e.address == ip);
    if (device == null) {
      debugPrint('Неизвестное устройство');
      return;
    }
    //device ??= deviceController.items.first;

    device.vibrationDetected();
    deviceController.deviceGroup.vibrationDetected(device);
    //selectNextDeviceGoldStation(deviceController, device);
    //deviceController.setRed(device, deviceController.currentItem.isRedOn);
  }

  Future selectNextDeviceGoldStation(DeviceController deviceController, Device device) async {
    play('beeplong');
    var oldRed = device.isRedOn;
    var oldBlue = device.isBlueOn;
    var oldGreen = device.isGreenOn;
    if (device.isRedOn) {
      await deviceController.setRed(device, false);
    }
    if (device.isBlueOn) {
      await deviceController.setBlue(device, false);
    }
    if (device.isGreenOn) {
      await deviceController.setGreen(device, false);
    }
    //if (deviceController.items.length == 1) {
    if (oldRed) {
      await deviceController.setBlue(device, true);
    }
    if (oldBlue) {
      await deviceController.setGreen(device, true);
    }
    if (oldGreen || (!oldGreen && !oldBlue && !oldRed)) {
      await deviceController.setRed(device, true);
    }
    //}
  }
}
