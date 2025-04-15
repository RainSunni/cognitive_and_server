import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:cognitive_training/model/enums/e_metronome_mode.dart';
import 'package:cognitive_training/pages/training_metronom/training_metronom_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_style_button.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';

import '../training/training_controller.dart';

class TrainingMetronomEditPage extends StatefulWidget {
  const TrainingMetronomEditPage({super.key, required this.item});

  final TrainingMetronom item;

  @override
  State<TrainingMetronomEditPage> createState() => _TrainingMetronomEditPageState();
}

class _TrainingMetronomEditPageState extends State<TrainingMetronomEditPage> {
  @override
  Widget build(BuildContext context) {
    var trainingMetronomC = Get.find<TrainingMetronomController>();
    trainingMetronomC.currentItem = widget.item;
    return Container(
      decoration: BoxDecoration(color: nsgtheme.colorMainBack),
      child: Column(
        children: [
          NsgLightAppBar(
            title: 'Метроном',
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
                  NsgInput(
                    dataItem: trainingMetronomC.currentItem,
                    fieldName: TrainingMetronomGenerated.nameMetronomeMode,
                    label: 'Режим метронома',
                    onEditingComplete: (p0, p1) {
                      setState(() {});
                    },
                  ),
                  NsgInput(
                      dataItem: trainingMetronomC.currentItem,
                      fieldName: TrainingMetronomGenerated.nameInitialBpm,
                      label:
                          trainingMetronomC.currentItem.metronomeMode == EMetronomeMode.normal ? 'Кол-во ударов в минуту' : 'Начальное к-во ударов в минуту'),
                  if (trainingMetronomC.currentItem.metronomeMode == EMetronomeMode.linear)
                    NsgInput(
                        dataItem: trainingMetronomC.currentItem, fieldName: TrainingMetronomGenerated.nameTargetBpm, label: 'Конечное к-во ударов в минуту'),
                  if (trainingMetronomC.currentItem.metronomeMode == EMetronomeMode.percentage)
                    NsgInput(dataItem: trainingMetronomC.currentItem, fieldName: TrainingMetronomGenerated.nameIntervalProcent, label: 'Процент изменения'),
                  if (trainingMetronomC.currentItem.metronomeMode == EMetronomeMode.percentage)
                    NsgInput(dataItem: trainingMetronomC.currentItem, fieldName: TrainingMetronomGenerated.nameDelayTime, label: 'Время перехода (сек.)'),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      children: [
                        NsgTextButton(
                          text: 'Удалить метроном',
                          color: nsgtheme.colorError,
                          padding: EdgeInsets.zero,
                          fontSize: 16,
                          onTap: () async {
                            trainingMetronomC.deleteItem(goBack: false);
                            var trainingC = Get.find<TrainingController>();
                            trainingC.currentItem.metronom = TrainingMetronom();
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
                      await trainingMetronomC.itemPagePost(goBack: false);
                      var trainingC = Get.find<TrainingController>();
                      if (trainingC.currentItem.metronom.isEmpty) {
                        trainingC.currentItem.metronom = trainingMetronomC.currentItem;
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
