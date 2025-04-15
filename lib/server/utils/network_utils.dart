// lib/utils/network_utils.dart
import 'dart:io';
import 'package:logging/logging.dart';

Future<String> getLocalIP([String subnet = '192.168.1']) async {
  final logger = Logger('NetworkUtils');

  for (var interface in await NetworkInterface.list()) {
    logger.info('Checking interface: ${interface.name}');

    for (var addr in interface.addresses) {
      if (addr.type == InternetAddressType.IPv4) {
        logger.info('Found IPv4 address: ${addr.address}');
        if (addr.address.startsWith(subnet)) {
          logger.info('Found IP in correct subnet: ${addr.address}');
          return addr.address;
        }
      }
    }
  }

  throw Exception('Could not find IP address in network $subnet');
}
