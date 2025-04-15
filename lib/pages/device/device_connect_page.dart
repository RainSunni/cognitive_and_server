import 'package:cognitive_training/pages/device/device_controller.dart';
import 'package:cognitive_training/pages/device/widgets/device_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_grid.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';
import 'package:nsg_data/nsg_data.dart';

import '../../app_pages.dart';

class DeviceConnectionPage extends StatelessWidget {
  const DeviceConnectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<DeviceController>();
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
                  leftIcons: [
                    NsgLigthAppBarIcon(
                        icon: Icons.arrow_left,
                        onTap: () {
                          var controller = Get.find<DeviceController>();
                          controller.stopServer();
                          NsgNavigator.pop();
                        })
                  ],
                  rightIcons: const [],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _getItems() {
    var controller = Get.find<DeviceController>();
    List<Widget> list = [];

    // list.add(
    //   NsgButton(
    //     text: 'Искать устройства',
    //     color: Colors.white,
    //     backColor: nsgtheme.colorPrimary,
    //     onPressed: () {
    //       controller.itemNewPageOpen(Routes.trainingEditPage);
    //     },
    //   ),
    // );

    var topItems = <Widget>[];
    if (!controller.isWiFiDetected) {
      topItems.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Нет WiFi'),
      ));
    }
    if (controller.isWiFiDetected) {
      topItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('ip address ${controller.ipAddress}'),
        ),
      );
    }
    if (controller.items.isEmpty) {
      topItems.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Подчиненных устройств не найдено'),
      ));
    }
    //if (controller.items.isEmpty) {
    topItems.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        child: const Text('ИСКАТЬ'),
        onPressed: () {
          controller.seachDevices();
        },
      ),
    ));
    //}

    if (controller.items.isNotEmpty) {
      topItems.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          child: Text('РЕЖИМ ${controller.deviceGroup.goalStationMode ? 'ГОЛ СТАНЦИИ' : 'ПРОИЗВОЛЬНЫЙ'}'),
          onPressed: () {
            controller.seachDevices();
          },
        ),
      ));
    }
    if (controller.items.length >= 3) {
      topItems.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          child: const Text('ВКЛ РЕЖИМ ГОЛ-СТАНЦИИ'),
          onPressed: () {
            controller.deviceGroup.goalStationMode = true;
          },
        ),
      ));
    }

    for (var item in controller.items) {
      list.add(InkWell(
        child: DeviceCard(device: item),
        onTap: () {
          if (controller.regime == NsgControllerRegime.selection && controller.onSelected != null) {
            controller.onSelected!(item);
          } else {
            controller.itemPageOpen(item, Routes.devicePage);
          }
        },
      ));
    }

    if (list.isNotEmpty) {
      topItems.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: NsgGrid(centered: false, vGap: 16, hGap: 16, crossAxisCount: 1, children: list),
      ));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: topItems);
  }
}
