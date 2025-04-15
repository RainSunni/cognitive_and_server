import 'package:get/get.dart';

import 'training_color_controller.dart';

// ignore: deprecated_member_use
class TrainingColorBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TrainingColorController());
  }
}
