import 'package:nsg_data/nsg_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

/// Режим метронома
class EMetronomeMode extends NsgEnum {
  static EMetronomeMode normal = EMetronomeMode(0, (AppLocalizations.of(Get.context!) as AppLocalizations).eMetronomeMode_normal);
  static EMetronomeMode linear = EMetronomeMode(1, (AppLocalizations.of(Get.context!) as AppLocalizations).eMetronomeMode_linear);
  static EMetronomeMode percentage = EMetronomeMode(2, (AppLocalizations.of(Get.context!) as AppLocalizations).eMetronomeMode_percentage);

  EMetronomeMode(dynamic value, String name) : super(value: value, name: name);

  @override
  void initialize() {
    NsgEnum.listAllValues[runtimeType] = <int, EMetronomeMode>{
      0: normal,
      1: linear,
      2: percentage,
    };
  }
}
