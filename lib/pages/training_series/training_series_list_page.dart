import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_grid.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';

import '../../app_pages.dart';
import '../../widgets/training_series_card.dart';
import 'training_series_controller.dart';

class TrainingSeriesListPage extends StatelessWidget {
  const TrainingSeriesListPage({Key? key}) : super(key: key);

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
                  // title: AppLocalizations.of(context)!.exerciseSeriesList,
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
                          child: _getItems(),
                        ),
                    onLoading: const NsgProgressBar(),
                    onError: (text) => Text(text ?? 'Неизвестная ошибка')),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: NsgButton(
                        text: 'Список упражнений',
                        color: Colors.white,
                        backColor: nsgtheme.colorPrimary,
                        onPressed: () {
                          controller.itemNewPageOpen(Routes.trainingListPage);
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: NsgButton(
                        text: 'Создать серию',
                        color: Colors.white,
                        backColor: nsgtheme.colorPrimary,
                        onPressed: () {
                          controller.itemNewPageOpen(Routes.trainingSeriesEditPage);
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

  Widget _getItems() {
    var controller = Get.find<TrainingSeriesController>();
    controller.items.sort((a, b) => b.dateEdited.compareTo(a.dateEdited));
    List<Widget> list = [];
    // Map<DateTime, List<Training>> groupedObjects = groupBy<Training, DateTime>(controller.items, (Training item) {
    //   return DateTime(item.date.year, item.date.month, item.date.day);
    // });
    // List<MapEntry<DateTime, List<Training>>> entries = groupedObjects.entries.toList();
    // List<Widget> list = [];
    // for (var entry in entries) {
    //   DateTime date = entry.key;

    if (controller.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            (Text('Список пуст')),
          ],
        ),
      );
    }

    for (var item in controller.items) {
      list.add(InkWell(
        child: TrainingSeriesCard(item: item),
        onTap: () {
          controller.itemPageOpen(item, Routes.trainingSeriesEditPage);
        },
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: NsgGrid(centered: false, vGap: 16, hGap: 16, crossAxisCount: 2, children: list),
    );
  }
}

/*
class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    var dateNow = DateTime.now();
    var textDate = '--.--.----';
    if (date.day == dateNow.day && date.month == dateNow.month && date.year == dateNow.year) {
      textDate = 'Сегодня';
    } else if (date.day == dateNow.day - 1 && date.month == dateNow.month && date.year == dateNow.year) {
      textDate = 'Вчера';
    } else {
      textDate = NsgDateFormat.dateFormat(date, format: 'dd.MM.yyyy');
    }
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Text(
            textDate,
            textAlign: TextAlign.left,
            style: const TextStyle(color: Color(0xFF1C1B1F), fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}*/
