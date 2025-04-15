import 'package:nsg_data/nsg_data.dart';

import 'generated/training.g.dart';

class Training extends TrainingGenerated {
  @override
  bool isFieldRequired(String fieldName) {
    if (fieldName == TrainingGenerated.nameDurationMinutes && useDurationMinutes ||
        fieldName == TrainingGenerated.nameDurationSeconds && !useDurationMinutes ||
        fieldName == TrainingGenerated.nameAudioCountdownToStart ||
        (math.isNotEmpty || colors.isNotEmpty) && fieldName == TrainingGenerated.nameTaskDelayTime) {
      return true;
    } else {
      return super.isFieldRequired(fieldName);
    }
  }

  @override
  NsgValidateResult validateFieldValues({NsgBaseController? controller}) {
    var answer = super.validateFieldValues(controller: controller);
    if (durationSeconds < 10 && !useDurationMinutes) {
      answer.isValid = false;
      var text = "Значение должно быть не менее 10 секунд";
      var field = TrainingGenerated.nameDurationSeconds;
      answer.fieldsWithError[field] = text;
    }
    if (durationMinutes < 1 && useDurationMinutes) {
      answer.isValid = false;
      var text = "Значение должно быть не менее 1 минуты";
      var field = TrainingGenerated.nameDurationMinutes;
      answer.fieldsWithError[field] = text;
    }
    if (audioCountdownToStart < 3) {
      answer.isValid = false;
      var text = "Значение должно быть не менее 3 секунд";
      var field = TrainingGenerated.nameAudioCountdownToStart;
      answer.fieldsWithError[field] = text;
    }
    if (taskDelayTime < 3 && (math.isNotEmpty || colors.isNotEmpty)) {
      answer.isValid = false;
      var text = "Значение должно быть не менее 3 секунд";
      var field = TrainingGenerated.nameTaskDelayTime;
      answer.fieldsWithError[field] = text;
    }

    return answer;
  }
}
