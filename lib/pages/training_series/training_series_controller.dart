import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';

class TrainingSeriesController extends NsgDataController<TrainingSeries> {
  TrainingSeriesController() : super();

  bool _isEditMode = false;

  bool get isEditMode {
    if (currentItem.state == NsgDataItemState.create || _isEditMode) {
      return true;
    } else {
      return false;
    }
  }

  set isEditMode(bool val) => _isEditMode = val;

  @override
  Future<bool> itemPagePost({bool goBack = true, bool useValidation = true}) {
    isEditMode = false;
    return super.itemPagePost(goBack: goBack, useValidation: useValidation);
  }

  @override
  void itemPageCancel({bool useValidation = true, required BuildContext context}) {
    isEditMode = false;
    super.itemPageCancel(context: context, useValidation: useValidation);
  }
}
