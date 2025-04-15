import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:cognitive_training/pages/training_color/training_color_controller.dart';
import 'package:cognitive_training/widgets/color_list_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_style_button.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';

import '../training/training_controller.dart';

class TrainingColorEditPage extends StatelessWidget {
  const TrainingColorEditPage({super.key, required this.item});

  final TrainingColors item;

  @override
  Widget build(BuildContext context) {
    var trainingColorC = Get.find<TrainingColorController>();

    trainingColorC.currentItem = item;
    List<Color> colors = [];
    if (trainingColorC.currentItem.colors.isNotEmpty) {
      for (var hexColor in trainingColorC.currentItem.colors.split(',')) {
        // colors.add(Color(int.parse(hexColor, radix: 16) + 0xFF000000));
        colors.add(stringToColor(hexColor));
      }
    }
    return Container(
      decoration: BoxDecoration(color: nsgtheme.colorMainBack),
      child: Column(
        children: [
          NsgLightAppBar(
            title: 'Цветовое задание',
            style: NsgLigthAppBarStyle(titleStyle: TextStyle(fontSize: nsgtheme.sizeXXL)),
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
                  ColorListPicker(
                      initColors: colors,
                      onChange: (colors) {
                        trainingColorC.currentItem.colors = colors.map((e) => e.toString()).join(',');
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        NsgTextButton(
                          text: 'Удалить цветовое задание',
                          color: nsgtheme.colorError,
                          padding: const EdgeInsets.only(top: 10),
                          fontSize: 16,
                          onTap: () async {
                            trainingColorC.deleteItem(goBack: false);
                            var trainingC = Get.find<TrainingController>();
                            trainingC.currentItem.colors = TrainingColors();
                            trainingC.sendNotify();
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
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
                      await trainingColorC.itemPagePost(goBack: false);
                      var trainingC = Get.find<TrainingController>();
                      if (trainingC.currentItem.colors.isEmpty) {
                        trainingC.currentItem.colors = trainingColorC.currentItem;
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
