import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:nsg_data/nsg_data.dart';

import 'device_http_slave.dart';

class DeviceSlaveController extends NsgDataController<Device> {
  final DeviceHttpSlaveApi deviceHttpApi = DeviceHttpSlaveApi();

  bool isWiFiDetected = false;
  String ipAddress = '';

  DeviceSlaveController() : super();

  void startServer() {
    deviceHttpApi.runServer();
  }

  void stopServer() {
    deviceHttpApi.stopServer();
  }
}
