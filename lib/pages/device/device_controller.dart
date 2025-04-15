import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:cognitive_training/pages/device/device_group.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nsg_data/nsg_data.dart';

import 'device_http_api.dart';

class DeviceController extends NsgDataController<Device> {
  final DeviceHttpApi deviceHttpApi = DeviceHttpApi();

  bool isWiFiDetected = false;
  String ipAddress = '';
  DeviceGroup deviceGroup = DeviceGroup();

  DeviceController() : super();

  void startServer() {
    deviceHttpApi.runServer();
  }

  void stopServer() {
    deviceHttpApi.stopServer();
  }

  Future seachDevices() async {
    var ipParts = ipAddress.split('.');
    if (ipParts.length != 4) {
      debugPrint('ERROR: ip not set');
      return;
    }
    var part1 = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}.';
    for (var i = 1; i < 20; i++) {
      if (i.toString() == ipParts[3]) continue;
      var ip = part1 + i.toString();
      var url = Uri.http(ip, 'getIP', {});
      try {
        debugPrint('SEARCH ip = $ip');
        var response = await http.get(url).timeout(const Duration(milliseconds: 500));
        debugPrint('FOUND ${response.body}');
        addDevice(response.body, ip);
        // ignore: empty_catches
      } catch (ex) {}
    }
  }

  void addDevice(String deviceId, String ip) {
    var device = (items.firstWhereOrNull((element) => element.id == deviceId)) ?? Device();
    if (device.isEmpty) {
      //Дабавляем новое устройство
      device.id = deviceId;
      device.address = ip;
      debugPrint('NEW DEVICE registered. id=$deviceId, ip=${device.address}');
      items.add(device);
      deviceGroup.addDevice(device);
      sendNotify();
      //Активируем датчик вибрации
      setVibrationDetector(device, true);
      //гасим все светодиоды
      setRed(device, false);
      setBlue(device, false);
      setGreen(device, false);
    } else {
      //Дабавляем новое устройство
      device.id = deviceId;
      device.address = ip;
      debugPrint('EXISTED DEVICE ping. id=$deviceId, ip=${device.address}');
    }
  }

  Future setRed(Device device, bool value) async {
    var url = Uri.http(device.address, value ? '/led/onRed' : '/led/offRed', {});
    try {
      var response = await http.get(url).timeout(const Duration(milliseconds: 2000));
      device.isRedOn = response.body == 'LED turned on';
      sendNotify();
    } catch (e) {
      debugPrint('ERROR setRed =$e');
    }
  }

  Future setGreen(Device device, bool value) async {
    var url = Uri.http(device.address, value ? '/led/onGreen' : '/led/offGreen', {});
    try {
      var response = await http.get(url).timeout(const Duration(milliseconds: 2000));
      device.isGreenOn = response.body == 'LED turned on';
      sendNotify();
    } catch (e) {
      debugPrint('ERROR setRed =$e');
    }
  }

  Future setBlue(Device device, bool value) async {
    var url = Uri.http(device.address, value ? '/led/onBlue' : '/led/offBlue', {});
    try {
      var response = await http.get(url).timeout(const Duration(milliseconds: 2000));
      device.isBlueOn = response.body == 'LED turned on';
      sendNotify();
    } catch (e) {
      debugPrint('ERROR setRed =$e');
    }
  }

  Future setVibrationDetector(Device device, bool value) async {
    var url = Uri.http(device.address, value ? '/vibra/on' : '/vibra/off', {});
    try {
      var response = await http.get(url).timeout(const Duration(milliseconds: 2000));
      device.isVibrationDetectorOn = response.body == 'vibra on';
      sendNotify();
    } catch (e) {
      debugPrint('ERROR setRed =$e');
    }
  }
}
