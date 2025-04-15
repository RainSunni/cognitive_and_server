import 'package:cognitive_training/app_pages.dart';
import 'package:cognitive_training/pages/training/training_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_style_button.dart';
import 'package:nsg_controls/widgets/nsg_dialog.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';
import 'package:nsg_data/nsg_data.dart';

import '../../model/generated/training.g.dart';
import '../../widgets/training_color_card.dart';
import '../../widgets/training_math_card.dart';
import '../../widgets/training_metronom_card.dart';
import '../training_color/training_color_edit_page.dart';
import '../training_math/training_math_edit_page.dart';
import '../training_metronom/training_metronom_edit_page.dart';

class TrainingEditPage extends StatefulWidget {
  const TrainingEditPage({Key? key}) : super(key: key);

  @override
  State<TrainingEditPage> createState() => _TrainingEditPageState();
}

class _TrainingEditPageState extends State<TrainingEditPage> {
  // var valid1 = '';
  // var valid2 = '';
  NsgDialogBodyController bodyController = NsgDialogBodyController();
  var controller = Get.find<TrainingController>();
  @override
  Widget build(BuildContext context) {
    return NsgDialogBody(
      controller: bodyController,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: nsgtheme.colorMainBack),
          child: BodyWrap(
            transparentBody: true,
            child: Column(
              children: [
                controller.obx((state) {
                  String title = controller.currentItem.state == NsgDataItemState.create
                      ? 'Новое упражнение'
                      : controller.isEditMode
                          ? 'Редактирование упражнения'
                          : 'Упражнение';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: NsgLightAppBar(
                      title: title,
                      style: NsgLigthAppBarStyle(titleStyle: TextStyle(fontSize: nsgtheme.sizeXXL)),
                      leftIcons: [
                        NsgLigthAppBarIcon(
                          icon: NsgIcons.chevron_left,
                          color: nsgtheme.colorTertiary,
                          onTap: () {
                            if (controller.isEditMode && controller.currentItem.state != NsgDataItemState.create) {
                              controller.isEditMode = false;
                              controller.sendNotify();
                            } else {
                              controller.itemPageCancel(context: context);
                            }
                          },
                        )
                      ],
                      rightIcons: [
                        if (!controller.isEditMode)
                          NsgLigthAppBarIcon(
                            icon: NsgIcons.edit,
                            color: const Color(0xFF1C1B1F),
                            onTap: () {
                              controller.isEditMode = true;
                              controller.sendNotify();
                            },
                          )
                      ],
                    ),
                  );
                }),
                Expanded(child: SingleChildScrollView(child: showTrainingList())),
                Column(
                  children: [
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
                                if (controller.isEditMode && controller.currentItem.state != NsgDataItemState.create) {
                                  controller.isEditMode = false;
                                  controller.sendNotify();
                                } else {
                                  controller.itemPageCancel(context: context);
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          controller.obx(
                            (state) => Expanded(
                              child: NsgButton(
                                text: controller.isEditMode ? 'Применить' : 'Старт',
                                color: Colors.white,
                                backColor: nsgtheme.colorPrimary,
                                onPressed: () async {
                                  if (controller.isEditMode) {
                                    if (controller.currentItem.state == NsgDataItemState.create) {
                                      controller.currentItem.date = DateTime.now();
                                    }
                                    var validationResult = controller.currentItem.validateFieldValues(controller: controller);
                                    // Если валидация не пройдена
                                    if (validationResult.fieldsWithError.isNotEmpty) {
                                      setState(() {});
                                    } else {
                                      await controller.itemPagePost(goBack: false);
                                      controller.isEditMode = false;
                                      controller.sendNotify();
                                    }
                                  } else {
                                    controller.trainingSeries = false;
                                    NsgNavigator.push(Routes.trainingSeriesScreenPage);
                                    //   Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    //     return GestureDetector(
                                    //         onTap: () {
                                    //           showNsgDialog(
                                    //             title: 'Идёт упражнение',
                                    //             text: 'Вы уверены, что хотите прервать выполняемое упражнение?',
                                    //             context: context,
                                    //             onConfirm: () {
                                    //               Navigator.pop(context);
                                    //             },
                                    //           );
                                    //         },
                                    //         child: TrainingScreenPage(options: controller.currentItem));
                                    //   }));
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showTrainingList() {
    List<Widget> list = [];

    list.addAll([
      controller.obx(
        (state) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!controller.isEditMode)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(controller.currentItem.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF1C1B1F), fontSize: 22, fontWeight: FontWeight.w600)),
                  ),
                  if (controller.currentItem.comment.isNotEmpty)
                    Text(controller.currentItem.comment,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: nsgtheme.colorTertiary, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(
                    height: 12,
                  ),
                  if (controller.currentItem.useDurationMinutes) _getFieldInfo('Длительность, минут', '${controller.currentItem.durationMinutes}'),
                  if (!controller.currentItem.useDurationMinutes) _getFieldInfo('Длительность, секунд', '${controller.currentItem.durationSeconds}'),
                  if (controller.currentItem.audioCountdownToStart != 0)
                    _getFieldInfo('Сигнал до начала упражнения, секунд', '${controller.currentItem.audioCountdownToStart}'),
                  if (controller.currentItem.audioCountdownToFinish != 0)
                    _getFieldInfo('Сигнал до завершения упражнения, секунд', '${controller.currentItem.audioCountdownToFinish}'),
                  if (controller.currentItem.beeperInterval != 0) _getFieldInfo('Интервал бипера, секунд', '${controller.currentItem.beeperInterval}'),
                  _getFieldInfo('Повторение математич. и цвет. заданий, секунд', '${controller.currentItem.taskDelayTime}'),
                ],
              ),
            if (controller.isEditMode)
              NsgInput(
                  dataItem: controller.currentItem,
                  fieldName: TrainingGenerated.nameName,
                  label: 'Название упражнения',
                  textCapitalization: TextCapitalization.sentences),
            if (controller.isEditMode)
              NsgInput(
                  dataItem: controller.currentItem,
                  fieldName: TrainingGenerated.nameComment,
                  label: 'Комментарий',
                  textCapitalization: TextCapitalization.sentences),
            if (controller.isEditMode)
              NsgInput(
                controller: controller,
                dataItem: controller.currentItem,
                fieldName: TrainingGenerated.nameUseDurationMinutes,
                label: 'Длительность в минутах',
                onEditingComplete: (p0, p1) {
                  setState(() {});
                },
              ),
            if (controller.isEditMode && controller.currentItem.useDurationMinutes)
              NsgInput(
                controller: controller,
                dataItem: controller.currentItem,
                fieldName: TrainingGenerated.nameDurationMinutes,
                label: 'Длительность упражнения, минут',
              ),
            if (controller.isEditMode && !controller.currentItem.useDurationMinutes)
              NsgInput(
                controller: controller,
                dataItem: controller.currentItem,
                fieldName: TrainingGenerated.nameDurationSeconds,
                label: 'Длительность упражнения, секунд',
              ),
            if (controller.isEditMode)
              NsgInput(
                controller: controller,
                dataItem: controller.currentItem,
                fieldName: TrainingGenerated.nameTaskDelayTime,
                label: 'Длительность задания (математич. и цветового)',
              ),
            if (controller.isEditMode)
              NsgInput(
                controller: controller,
                dataItem: controller.currentItem,
                fieldName: TrainingGenerated.nameAudioCountdownToStart,
                label: 'Время подготовки к упражнению N секунд (>3 секунд)',
                // validateText: valid2,
              ),
            if (controller.isEditMode)
              NsgInput(
                controller: controller,
                dataItem: controller.currentItem,
                fieldName: TrainingGenerated.nameRelaxTime,
                label: 'Время отдыха после упражнения, сек',
                onEditingComplete: (p0, p1) {
                  setState(() {});
                },
              ),
            if (controller.isEditMode)
              NsgInput(
                  dataItem: controller.currentItem,
                  fieldName: TrainingGenerated.nameAudioCountdownToFinish,
                  label: 'Звук за N секунд перед завершением упражнения (0 - выкл)'),
            if (controller.isEditMode)
              NsgInput(
                  dataItem: controller.currentItem, fieldName: TrainingGenerated.nameBeeperInterval, label: 'Повторяющийся каждые N секунд сигнал (0 - выкл)'),
            Row(
              children: [
                NsgTextButton(
                  text: 'Удалить упражнение',
                  color: nsgtheme.colorError,
                  padding: const EdgeInsets.only(top: 10),
                  fontSize: 16,
                  onTap: () async {
                    await controller.deleteItem();
                  },
                )
              ],
            ),
          ]),
        ),
      ),
      const SizedBox(height: 15),
      controller.obx((state) => Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Column(
              children: [
                /* ------------------------------------------------- Математическое ------------------------------------------------- */
                // if (controller.currentItem.math.isNotEmpty || controller.isEditMode)

                InkWell(
                    child: TrainingMathCard(data: controller.currentItem.math),
                    onTap: () {
                      if (!controller.isEditMode) return;
                      bodyController.openDialog(TrainingMathEditPage(
                        item: controller.currentItem.math,
                      ));
                    }),
              ],
            ),
          )),
      Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: controller.obx((state) => Column(
              children: [
                /* ---------------------------------------------------- Цветовое ---------------------------------------------------- */
                // if (controller.currentItem.colors.isNotEmpty || controller.isEditMode)

                InkWell(
                    child: TrainingColorCard(data: controller.currentItem.colors),
                    onTap: () {
                      if (!controller.isEditMode) return;
                      bodyController.openDialog(TrainingColorEditPage(
                        item: controller.currentItem.colors,
                      ));
                    }),
              ],
            )),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: controller.obx((state) => Column(
              children: [
                /* ---------------------------------------------------- Метроном ---------------------------------------------------- */
                // if (controller.currentItem.metronom.isNotEmpty || controller.isEditMode)

                InkWell(
                    child: TrainingMetronomCard(data: controller.currentItem.metronom),
                    onTap: () {
                      if (!controller.isEditMode) return;
                      bodyController.openDialog(TrainingMetronomEditPage(
                        item: controller.currentItem.metronom,
                      ));
                    }),
              ],
            )),
      ),
      const SizedBox(height: 50)
    ]);
    return Column(
      children: list,
    );
  }

  Widget _getFieldInfo(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(color: Color(0xFF1C1B1F), fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(color: nsgtheme.colorTertiary, fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
