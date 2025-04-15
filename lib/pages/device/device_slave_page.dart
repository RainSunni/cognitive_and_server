import 'package:cognitive_training/pages/device/widgets/device_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_grid.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';
import 'package:nsg_data/navigator/nsg_navigator.dart';

import '../../app_pages.dart';
import 'device_slave_controller.dart';

class DeviceSlavePage extends StatelessWidget {
  const DeviceSlavePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<DeviceSlaveController>();
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
                  rightIcons: const [],
                  leftIcons: [
                    NsgLigthAppBarIcon(
                        icon: Icons.arrow_left,
                        onTap: () {
                          var controller = Get.find<DeviceSlaveController>();
                          controller.stopServer();
                          NsgNavigator.pop();
                        })
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _getItems() {
    var controller = Get.find<DeviceSlaveController>();
    List<Widget> list = [];

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

    for (var item in controller.items) {
      list.add(InkWell(
        child: DeviceCard(device: item),
        onTap: () {
          if (controller.regime == NsgControllerRegime.selection && controller.onSelected != null) {
            controller.onSelected!(item);
          } else {
            controller.itemPageOpen(item, Routes.trainingEditPage);
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
