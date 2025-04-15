import 'package:get/get.dart';

import '../training_color/training_color_controller.dart';
import '../training_math/training_math_controller.dart';
import '../training_metronom/training_metronom_controller.dart';
import '../training_series/training_series_controller.dart';
import 'training_controller.dart';

// ignore: deprecated_member_use
class TrainingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TrainingController(), permanent: true);
    Get.put(TrainingSeriesController(), permanent: true);
    Get.put(TrainingMathController(), permanent: true);
    Get.put(TrainingColorController(), permanent: true);
    Get.put(TrainingMetronomController(), permanent: true);
  }
}
