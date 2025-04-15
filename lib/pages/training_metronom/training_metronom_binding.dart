import 'package:get/get.dart';

import 'training_metronom_controller.dart';

// ignore: deprecated_member_use
class TrainingMetronomBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TrainingMetronomController());
  }
}
