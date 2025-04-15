import 'dart:io';

import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'device_slave_controller.dart';

class DeviceHttpSlaveApi {
  HttpServer? _server;
  final port = 5900;

  DeviceHttpSlaveApi();

  Future<void> runServer() async {
    final info = NetworkInfo();
    var deviceController = Get.find<DeviceSlaveController>();
    deviceController.ipAddress = (await info.getWifiIP()) ?? '';
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
        if (segments.isEmpty) {
          request.response.statusCode = HttpStatus.badRequest;
        }
        debugPrint(uri.toString());

        if (segments[0] == 'get-guid') {
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
        }

        request.response.write('OK');
        await request.response.close();
      }
    }
  }

  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close();
    }
  }
}
