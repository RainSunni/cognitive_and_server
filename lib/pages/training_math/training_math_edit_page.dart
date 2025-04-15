import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:cognitive_training/pages/training_math/training_math_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_style_button.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';

import '../training/training_controller.dart';

class TrainingMathEditPage extends StatelessWidget {
  const TrainingMathEditPage({super.key, required this.item});

  final TrainingMath item;

  @override
  Widget build(BuildContext context) {
    var trainingMathC = Get.find<TrainingMathController>();
    trainingMathC.currentItem = item;
    return Container(
      decoration: BoxDecoration(
        color: nsgtheme.colorMainBack,
      ),
      child: Column(
        children: [
          NsgLightAppBar(
            title: 'Математическое задание',
            style: const NsgLigthAppBarStyle(titleStyle: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1C1B1F))),
            leftIcons: [
              NsgLigthAppBarIcon(
                icon: NsgIcons.chevron_left,
                color: nsgtheme.colorTertiary,
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(children: [
                  NsgInput(dataItem: trainingMathC.currentItem, fieldName: TrainingMathGenerated.nameMinNumber, label: 'Минимальное число'),
                  NsgInput(dataItem: trainingMathC.currentItem, fieldName: TrainingMathGenerated.nameMaxNumber, label: 'Максимальное число'),
                  NsgInput(
                    dataItem: trainingMathC.currentItem,
                    fieldName: TrainingMathGenerated.nameUseAddition,
                    label: 'Операция сложение',
                  ),
                  NsgInput(
                    dataItem: trainingMathC.currentItem,
                    fieldName: TrainingMathGenerated.nameUseSubtraction,
                    label: 'Операция вычитание',
                  ),
                  NsgInput(
                    dataItem: trainingMathC.currentItem,
                    fieldName: TrainingMathGenerated.nameUseMultiplication,
                    label: 'Операция умножение',
                  ),
                  const Divider(),
                  Row(
                    children: [
                      NsgTextButton(
                        text: 'Удалить математическое задание',
                        color: nsgtheme.colorError,
                        padding: const EdgeInsets.only(top: 10),
                        fontSize: 16,
                        onTap: () async {
                          trainingMathC.deleteItem(goBack: false);
                          var trainingC = Get.find<TrainingController>();
                          trainingC.currentItem.math = TrainingMath();
                          trainingC.sendNotify();
                          Navigator.pop(context);
                        },
                      )
                    ],
                  )
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: NsgButton(
                    text: 'Отмена',
                    color: Colors.white,
                    backColor: nsgtheme.colorTertiary,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: NsgButton(
                    text: 'Добавить',
                    color: Colors.white,
                    backColor: nsgtheme.colorPrimary,
                    onPressed: () async {
                      await trainingMathC.itemPagePost(goBack: false);
                      var trainingC = Get.find<TrainingController>();
                      if (trainingC.currentItem.math.isEmpty) {
                        trainingC.currentItem.math = trainingMathC.currentItem;
                      }
                      Get.find<TrainingController>().sendNotify();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
