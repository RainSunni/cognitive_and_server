import 'package:get/get.dart';

import 'training_math_controller.dart';

// ignore: deprecated_member_use
class TrainingMathBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TrainingMathController());
  }
}
