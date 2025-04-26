import 'package:cognitive_training/pages/training/training_controller.dart';
import 'package:cognitive_training/widgets/training_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_grid.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:cognitive_training/server/main_app.dart'; // Импорт серверного интерфейса
import 'package:cognitive_training/server/main_app.dart';
import 'package:cognitive_training/server/server_main.dart';
import 'package:cognitive_training/slave/slave_device_screen.dart';


import '../../app_pages.dart';
import '../device/device_controller.dart';
import '../device/device_slave_controller.dart';

class TrainingListPage extends StatelessWidget {
  const TrainingListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<TrainingController>();
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
                  title: AppLocalizations.of(context)!.exerciseList,
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
                child: Column(children: [
                  Row(
                    children: [
                      Expanded(
                        child: NsgButton(
                          text: 'Серии упражнений',
                          color: Colors.white,
                          backColor: nsgtheme.colorPrimary,
                          onPressed: () {
                            controller.itemNewPageOpen(Routes.trainingSeriesListPage);
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: NsgButton(
                          text: 'Создать упражнение',
                          color: Colors.white,
                          backColor: nsgtheme.colorPrimary,
                          onPressed: () {
                            controller.itemNewPageOpen(Routes.trainingEditPage);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: NsgButton(
                          text: 'Управление устройствами',
                          color: Colors.white,
                          backColor: nsgtheme.colorPrimary,
                          onPressed: () async {
                            await ServerLauncher.launchInContext(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: NsgButton(
                          text: 'Slave режим',
                          color: Colors.white,
                          backColor: nsgtheme.colorPrimary,
                          onPressed: () {

                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SlaveDeviceScreen() ),
                            ); //Navigator.push
                          }, // onPresser
                        ),
                      ),
                    ],
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getItems() {
    var controller = Get.find<TrainingController>();
    controller.items.sort((a, b) => b.date.compareTo(a.date));
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
        child: TrainingCard(item: item),
        onTap: () {
          if (controller.regime == NsgControllerRegime.selection && controller.onSelected != null) {
            controller.onSelected!(item);
          } else {
            controller.itemPageOpen(item, Routes.trainingEditPage);
          }
        },
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: NsgGrid(centered: false, vGap: 16, hGap: 16, crossAxisCount: 2, children: list),
    );
  }
}

// ignore: unused_element
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
      textDate = NsgDateFormat.dateFormat(date, format: 'dd.MM.yyyy', locale: 'ru');
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
}
