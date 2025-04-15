import 'package:nsg_data/nsg_data.dart';

class NsgServerOptions {
  static String get serverUriDataController => availableServers.currentServer;

  static NsgServerParams availableServers = NsgServerParams({'': 'main'}, '');
}

class NsgMetricaOptions {
  static String yandexMetricaId = "";
}
