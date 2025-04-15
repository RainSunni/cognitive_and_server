import 'package:cognitive_training/pages/device/device_controller.dart';
import 'package:get/get.dart';

// ignore: deprecated_member_use
class DeviceBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DeviceController(), permanent: true);
  }
}
