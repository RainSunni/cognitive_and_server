import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:cognitive_training/pages/training/training_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';
import 'package:nsg_controls/widgets/nsg_slidable_item.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';
import 'package:nsg_data/nsg_data.dart';

import '../../app_pages.dart';
import '../../widgets/training_card.dart';
import 'training_series_controller.dart';

class TrainingSeriesEditPage extends StatelessWidget {
  const TrainingSeriesEditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<TrainingSeriesController>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: nsgtheme.colorMainBack),
        child: BodyWrap(
          transparentBody: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NsgLightAppBar(
                  //TODO: LOCALIZE
                  title: 'Список тренировок',
                  //title: AppLocalizations.of(context)!.exerciseSeriesList,
                  style: NsgLigthAppBarStyle(titleStyle: TextStyle(fontSize: nsgtheme.sizeXXL)),
                  rightIcons: const [
                    // NsgLigthAppBarIcon(
                    //   icon: NsgIcons.filter,
                    //   color: const Color(0xFF1C1B1F),
                    //   onTap: () {},
                    // )
                  ],
                ),
              ),
              Expanded(
                child: controller.obx(
                    (state) => SingleChildScrollView(
                          child: _getItem(),
                        ),
                    onLoading: const NsgProgressBar(),
                    onError: (text) => Text(text ?? 'Неизвестная ошибка')),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: NsgButton(
                        text: 'Запустить серию',
                        onPressed: () {
                          Get.find<TrainingController>().trainingSeries = true;
                          NsgNavigator.push(Routes.trainingSeriesScreenPage);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: NsgButton(
                        text: 'Отмена',
                        color: nsgtheme.colorBase,
                        backColor: nsgtheme.colorTertiary,
                        onPressed: () {
                          NsgNavigator.push(Routes.trainingSeriesListPage);
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: NsgButton(
                        text: 'Сохранить',
                        color: Colors.white,
                        backColor: nsgtheme.colorPrimary,
                        onPressed: () {
                          controller.itemPagePost(goBack: false);
                          NsgNavigator.push(Routes.trainingSeriesListPage);
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getItem() {
    var controller = Get.find<TrainingSeriesController>();
    //  if (controller.isEditMode) {

    Widget trainingList() {
      List<Widget> list = [];
      for (var row in controller.currentItem.table.rows) {
        list.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: NsgSlidableItem(
            extentRatio: .2,
            buttonsListEnd: [
              SlidableAction(
                icon: Icons.delete,
                backgroundColor: nsgtheme.colorError.c40,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                onPressed: (context) {
                  controller.currentItem.table.removeRow(row);
                  controller.sendNotify();
                },
              ),
            ],
            child: Container(
              decoration: BoxDecoration(color: nsgtheme.colorPrimary.withAlpha(25), borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: trainingInfo(item: row.training)),
                      SizedBox(
                        width: 60,
                        child: NsgInput(
                          margin: EdgeInsets.zero,
                          controller: controller,
                          dataItem: row,
                          showDeleteIcon: false,
                          fieldName: TrainingSeriesTableRowGenerated.namePauseSeconds,
                          label: 'Пауза, сек',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
      }
      return Column(
        children: list,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          NsgInput(
              controller: controller,
              dataItem: controller.currentItem,
              fieldName: TrainingSeriesGenerated.nameName,
              label: 'Название серии',
              textCapitalization: TextCapitalization.sentences),
          NsgInput(
              controller: controller,
              dataItem: controller.currentItem,
              minLines: 1,
              maxLines: 3,
              fieldName: TrainingSeriesGenerated.nameComment,
              label: 'Описание',
              textCapitalization: TextCapitalization.sentences),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 5),
            child: Text(
              'Упражнения:',
              style: TextStyle(fontSize: nsgtheme.sizeL),
            ),
          ),
          trainingList(),
          NsgButton(
            text: 'Добавить упражнение',
            icon: Icons.add,
            onTap: () {
              var trainC = Get.find<TrainingController>();
              trainC.regime = NsgControllerRegime.selection;
              trainC.onSelected = (item) {
                trainC.regime = NsgControllerRegime.view;
                TrainingSeriesTableRow row = TrainingSeriesTableRow();
                row.training = item as Training;
                controller.currentItem.table.addRow(row);
                controller.sendNotify();
                NsgNavigator.push(Routes.trainingSeriesEditPage);
              };
              NsgNavigator.push(Routes.trainingListPage);
            },
          ),
          const SizedBox(height: 40)
        ],
      ),
    );
  }
}
