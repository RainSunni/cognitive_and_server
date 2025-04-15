import 'package:cognitive_training/pages/device/device_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';

class DevicePage extends StatelessWidget {
  const DevicePage({Key? key}) : super(key: key);

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

    var topItems = <Widget>[];
    if (controller.currentItem.isEmpty) {
      topItems.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Нет выбранного устройства'),
      ));
    } else {
      topItems.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('IP address = ${controller.currentItem.address}'),
      ));

      //LAMPS
      topItems.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: () => controller.setRed(controller.currentItem, !controller.currentItem.isRedOn),
              child: Container(width: 50, height: 50, color: Colors.red, child: Center(child: Container(width: 20, height: 20, color: Colors.white))),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: () => controller.setGreen(controller.currentItem, !controller.currentItem.isGreenOn),
              child: Container(width: 50, height: 50, color: Colors.green, child: Center(child: Container(width: 20, height: 20, color: Colors.white))),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: () => controller.setBlue(controller.currentItem, !controller.currentItem.isBlueOn),
              child: Container(width: 50, height: 50, color: Colors.blue, child: Center(child: Container(width: 20, height: 20, color: Colors.white))),
            ))
      ]));

      topItems.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          child: controller.currentItem.isVibrationDetectorOn ? const Text('ВИБРАЦИЯ ВЫКЛЮЧИТЬ') : const Text('ВИБРАЦИЯ ВКЛЮЧИТЬ'),
          onPressed: () {
            controller.setVibrationDetector(controller.currentItem, !controller.currentItem.isVibrationDetectorOn);
          },
        ),
      ));

      // topItems.add(Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 20),
      //   child: ('RED = ${controller.currentItem.isRedOn}'),
      // ));
      // topItems.add(Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 20),
      //   child: Text('IP address = ${controller.currentItem.address}'),
      // ));
    }

    // if (list.isNotEmpty) {
    //   topItems.add(Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 20),
    //     child: NsgGrid(centered: false, vGap: 16, hGap: 16, crossAxisCount: 1, children: list),
    //   ));
    // }
    return Column(mainAxisSize: MainAxisSize.min, children: topItems);
  }
}
