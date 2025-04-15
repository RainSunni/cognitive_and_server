import 'package:get/get.dart';

import 'device_slave_controller.dart';

// ignore: deprecated_member_use
class DeviceSlaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DeviceSlaveController(), permanent: true);
  }
}
