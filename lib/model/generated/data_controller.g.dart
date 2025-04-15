import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';

import '../data_controller_model.dart';
import '../enums.dart';
import '../options/server_options.dart';

class DataControllerGenerated extends NsgBaseController {
  NsgDataProvider? provider;
  @override
  Future onInit() async {
    final info = await PackageInfo.fromPlatform();
    NsgMetrica.reportAppStart();
    provider ??= NsgDataProvider(
        applicationName: 'cognitive_training', applicationVersion: info.version, firebaseToken: '', availableServers: NsgServerOptions.availableServers);
    provider!.serverUri = NsgServerOptions.serverUriDataController;

    NsgDataClient.client.registerDataItem(Training(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(TrainingColors(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(TrainingMath(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(TrainingMetronom(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(FavoriteItem(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(TrainingSeries(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(TrainingSeriesTableRow(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(UserSettings(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(ExchangeRules(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(ExchangeRulesMergingTable(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(Device(), remoteProvider: provider);
    NsgDataClient.client.registerDataItem(EMetronomeMode(0, ''), remoteProvider: provider);
    await NsgLocalDb.instance.init(provider!.applicationName);
    provider!.useNsgAuthorization = true;
    var db = NsgLocalDb.instance;
    //await db.init('cognitive_training');
    await provider!.connect(this);

    super.onInit();
  }

  @override
  Future loadProviderData() async {
    currentStatus = GetStatus.success(NsgBaseController.emptyData);
    sendNotify();
  }
}
