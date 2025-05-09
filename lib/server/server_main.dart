import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cognitive_training/server/main_app.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:flutter/material.dart'
    hide Router; // Скрываем Router из Flutter
import 'utils/network_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppLifecycleManager {
  static bool wasCleanExit = true;

  static void markDirtyExit() {
    wasCleanExit = false;
  }

  static void markCleanExit() {
    wasCleanExit = true;
  }

  // Определение через жизненный цикл приложения
  static void init() {
    WidgetsBinding.instance.addObserver(AppLifecycleListener(
      onExitRequested: () {
        markCleanExit();
        return Future.value(AppExitResponse.exit);
      },
    ));
  }
}

// Класс для хранения информации об известном устройстве
class KnownDevice {
  final String guid;
  final String ipAddress;
  final int port; //добавляем знания о порте устройства
  final DateTime lastSeen;

  KnownDevice({
    required this.guid,
    required this.ipAddress,
    required this.port,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
        'guid': guid,
        'ipAddress': ipAddress,
        'port': port,
        'lastSeen': lastSeen.toIso8601String(),
      };

  factory KnownDevice.fromJson(Map<String, dynamic> json) => KnownDevice(
        guid: json['guid'],
        ipAddress: json['ipAddress'],
        port: json['port'] ?? 80,
        lastSeen: DateTime.parse(json['lastSeen']),
      );
}

class Device {
  final WebSocketChannel socket;
  final String guid;
  final String ipAddress;
  final DateTime connectedAt;
  DateTime lastActivity;
  bool matrixState = false;
  int vibrationCount = 0;
  double? batteryVoltage;

  Device({
    required this.socket,
    required this.guid,
    required this.ipAddress,
    required this.connectedAt,
    required this.lastActivity,
    this.batteryVoltage,
  });
}

class ESP32Server {
  final Map<String, Device> devices = {};
  final Logger logger = Logger('ESP32Server');
  final Map<String, KnownDevice> knownDevices = {};
  final router = Router();
  final int port;
  final String subnet;
  late String serverIp;
  final String knownDevicesPath = 'known_devices.json';
  String shutdownFlagPath = 'shutdown_flag.txt'; // Убрали final
  bool isShuttingDown = false;
  Timer? inactivityCheckTimer;
  final Duration inactivityTimeout = const Duration(minutes: 1);
  static int _instanceCount = 0;
  static int _handleWebSocketCallCount = 0;

  static ESP32Server? _instance; // Единственный экземпляр
  HttpServer? _server; // Серверный сокет
  bool _isRunning = false; // Флаг, чтобы отслеживать состояние сервера

  // Приватный конструктор
  ESP32Server._internal({this.port = 5900, this.subnet = '192.168.1'}) {
    _instanceCount++;
    print('Создан экземпляр ESP32Server. Всего экземпляров: $_instanceCount');
    _loadKnownDevices(); // Загрузка устройств при создании
  }

  // ESP32Server({this.port = 5900, this.subnet = '10.11.0'}) {
  /*ESP32Server({this.port = 5900, this.subnet = '192.168.1'}) {
    _instanceCount++;
    print('Создан экземпляр ESP32Server. Всего экземпляров: $_instanceCount');
    _setupRoutes();
    _loadKnownDevices();
  }*/

  // Фабричный конструктор для Singleton
  factory ESP32Server({int port = 5900, String subnet = '192.168.1'}) {
    _instance ??= ESP32Server._internal(port: port, subnet: subnet);
    return _instance!;
  }

  void startInactivityCheck() {
    inactivityCheckTimer?.cancel();
    inactivityCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      checkDevicesActivity();
    });
    logger.info('Inactivity check timer started/reset');
  }

  void checkDevicesActivity() {
    final now = DateTime.now();
    final devicesToRemove = <String>[];

    for (var entry in devices.entries) {
      final timeSinceLastActivity = now.difference(entry.value.lastActivity);
      if (timeSinceLastActivity > inactivityTimeout) {
        logger.info(
            'Device ${entry.key} inactive for ${timeSinceLastActivity.inMinutes} minutes, disconnecting');
        devicesToRemove.add(entry.key);
        try {
          entry.value.socket.sink.close();
        } catch (e) {
          logger.warning('Error closing socket for device ${entry.key}: $e');
        }
      }
    }

    // Удаляем неактивные устройства
    for (var deviceId in devicesToRemove) {
      devices.remove(deviceId);
    }
  }

  // Загрузка известных устройств из файла
  void _loadKnownDevices() {
    try {
      final file = File(knownDevicesPath);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final List<dynamic> jsonList = jsonDecode(content);
        for (var item in jsonList) {
          final device = KnownDevice.fromJson(item);
          knownDevices[device.guid] = device;
        }
        logger.info('Loaded ${knownDevices.length} known devices');
      }
    } catch (e) {
      logger.warning('Error loading known devices: $e');
    }
  }

  // Сохранение известных устройств в файл
  void _saveKnownDevices() {
    try {
      final file = File(knownDevicesPath);
      final jsonList =
          knownDevices.values.map((device) => device.toJson()).toList();
      file.writeAsStringSync(jsonEncode(jsonList));
      logger.info('Saved ${knownDevices.length} known devices');
    } catch (e) {
      logger.warning('Error saving known devices: $e');
    }
  }

  Future<void> disconnectDevices() async {
    logger.info('Disconnecting devices ...');

    // Отключаем все текущие соединения
    for (var device in devices.values) {
      try {
        await device.socket.sink.close();
      } catch (e) {
        logger.warning('Error closing connection: $e');
      }
    }
    devices.clear();

    logger.info('All known devices cleared and connections closed');
  }

  // Функция очистки списка известных устройств
  Future<void> clearKnownDevices() async {
    logger.info('Clearing known devices list...');
    knownDevices.clear();
    _saveKnownDevices();

    // Отключаем все текущие соединения
    for (var device in devices.values) {
      try {
        await device.socket.sink.close();
      } catch (e) {
        logger.warning('Error closing connection: $e');
      }
    }
    devices.clear();

    logger.info('All known devices cleared and connections closed');
  }

  void _setupRoutes() {
    // WebSocket endpoint
    router.get('/', webSocketHandler((WebSocketChannel socket) {
      _handleWebSocket(socket);
    }));
  }

  // Новая функция для подключения известных устройств
  Future<void> connectKnownDevices() async {
    logger.info('Connecting to known devices...');

    // Создаем Set уникальных IP адресов
    final uniqueDevices = <String, KnownDevice>{};
    for (var device in knownDevices.values) {
      // Если IP уже есть в списке, берем устройство с более поздним временем подключения
      if (!uniqueDevices.containsKey(device.ipAddress) ||
          uniqueDevices[device.ipAddress]!.lastSeen.isBefore(device.lastSeen)) {
        uniqueDevices[device.ipAddress] = device;
      }
    }

    for (var device in uniqueDevices.values) {
      // Проверяем, нет ли уже подключенного устройства с этим IP
      if (devices.values.any((d) => d.ipAddress == device.ipAddress)) {
        logger.info(
            'Device at IP ${device.ipAddress} is already connected, skipping');
        continue;
      }

      try {
        logger.info(
            'Attempting to connect to known device ${device.guid} at ${device.ipAddress}');

        final ws = await WebSocket.connect('ws://${device.ipAddress}:${device.port}') //подключем не к конкретному порту, а к полученному
            .timeout(const Duration(milliseconds: 4000));

        final socket = IOWebSocketChannel(ws);
        _handleWebSocket(socket, device.ipAddress);

        // Ждем короткое время, чтобы позволить устройству идентифицироваться
        await Future.delayed(const Duration(milliseconds: 1000));

        logger.info('Successfully connected to known device ${device.guid}');
      } catch (e) {
        logger.warning('Failed to connect to known device ${device.guid}: $e');
      }
    }
  }

  Future<void> resetAndRescan() async {
    logger.info('Closing all existing connections...');
    for (var device in devices.values) {
      try {
        await device.socket.sink.close();
      } catch (e) {
        logger.warning('Error closing connection: $e');
      }
    }
    devices.clear();
    logger.info('Waiting 6 seconds for connections to fully close...');
    await Future.delayed(const Duration(seconds: 6));

    logger.info('Starting network scan...');
    await scanNetwork();
  }

  // Future<void> scanNetwork() async {
  //   logger.info('Starting network scan for ESP devices...');

  //   // Создаем список Future для параллельного сканирования
  //   List<Future<void>> scanFutures = [];

  //   for (int i = 99; i <= 110; i++) {
  //     final ip = '$subnet.$i';

  //     // Создаем Future для каждого IP
  //     var scanFuture = () async {
  //       try {
  //         logger.info('Scanning IP: $ip');

  //         final ws = await WebSocket.connect('ws://$ip:80')
  //             .timeout(const Duration(milliseconds: 4000));

  //         final socket = IOWebSocketChannel(ws);
  //         logger.info('Connected to WebSocket at $ip');

  //         _handleWebSocket(socket, ip);
  //       } catch (e) {
  //         logger.fine('Could not connect to $ip: $e');
  //       }
  //     }();

  //     scanFutures.add(scanFuture);
  //   }

  //   // Ждем завершения всех сканирований
  //   await Future.wait(scanFutures, eagerError: false);
  //   logger.info('Network scan complete');
  // }

  Future<void> scanNetwork() async {
    logger.info('Starting network scan for ESP devices...');

    // Создаем список Future для параллельного сканирования
    final scanFutures = <Future<void>>[];

    for (int i = 0; i <= 10; i++) {
      final ip = '$subnet.$i';

      // Создаем Future для каждого IP ОДИН раз
      final scanFuture = () async {
        try {
          final ws = await WebSocket.connect('ws://$ip:80')
              .timeout(const Duration(milliseconds: 4000));

          final socket = IOWebSocketChannel(ws);
          logger.info('Connected to WebSocket at $ip');

          _handleWebSocket(socket, ip);
        } catch (e) {
          logger.fine('Could not connect to $ip: $e');
        }
      }();

      scanFutures.add(scanFuture);
    }

    // Ждем завершения всех сканирований
    await Future.wait(scanFutures, eagerError: false);
    logger.info('Network scan complete');
    print("Завершено");
  }

  void _handleWebSocket(WebSocketChannel socket, [String ipAddress = '']) {
    _handleWebSocketCallCount++;
    logger.info(
        'Вызов _handleWebSocket #$_handleWebSocketCallCount для IP: $ipAddress');

    String? deviceId;
    bool isConnected = true;

    void cleanupState() {
      isConnected = false;

      if (deviceId != null) {
        logger.info('Connection closed for device $deviceId');
        devices.remove(deviceId);
      }
    }

    socket.stream.listen(
      (message) async {
        if (!isConnected) return;

        try {
          logger.info('Received data: $message');
          final data = jsonDecode(message);
          final messageType = data['type'];

          switch (messageType) {
            case 'identify':
              deviceId = data['deviceId'];
              logger.info('Device identified: $deviceId at $ipAddress');

              knownDevices[deviceId!] = KnownDevice(
                guid: deviceId!,
                ipAddress: ipAddress,
                port: data['port'] ?? 80, //добавляем порт
                lastSeen: DateTime.now(),
              );
              _saveKnownDevices(); // Сохраняем на диск

              if (devices.containsKey(deviceId)) {
                var existingDevice = devices[deviceId]!;
                var connectionAge =
                    DateTime.now().difference(existingDevice.connectedAt);

                // Если соединение свежее (менее 5 секунд), игнорируем повторную идентификацию
                if (connectionAge.inSeconds < 5) {
                  logger.info(
                      'Ignoring identify for recent connection of device $deviceId');
                  break;
                }

                // Иначе закрываем старое соединение
                logger.info(
                    'Device $deviceId already exists, closing old connection');
                await existingDevice.socket.sink.close();
                devices.remove(deviceId);
              }

              devices[deviceId!] = Device(
                socket: socket,
                guid: deviceId!,
                ipAddress: ipAddress,
                connectedAt: DateTime.now(),
                lastActivity: DateTime.now(),
              );

              startInactivityCheck();
              Future.delayed(const Duration(seconds: 1), () {
                if (devices.containsKey(deviceId)) {
                  final confirmCommand = {
                    'type': 'matrix_control',
                    'matrix1': {
                      'color': 'green',
                      'state': true,
                    },
                    'matrix2': {
                      'color': 'green',
                      'state': true,
                    }
                  };
                  socket.sink.add(jsonEncode(confirmCommand));
                  logger.info(
                      'Отправлена команда подтверждения устройству $deviceId');
                }
              });
              break;

            case 'vibration':
              if (deviceId != null && devices.containsKey(deviceId)) {
                var device = devices[deviceId]!;
                device.lastActivity = DateTime.now();
                device.vibrationCount++;
                logger.info(
                    'Vibration from device $deviceId (count: ${device.vibrationCount})');

                startInactivityCheck();
                device.matrixState = device.vibrationCount % 2 == 1;
                final ledCommand = {
                  'type': 'led',
                  'state': device.matrixState,
                };
                socket.sink.add(jsonEncode(ledCommand));
              }
              break;

            case 'battery_level':
              if (deviceId != null && devices.containsKey(deviceId)) {
                var device = devices[deviceId]!;
                final voltage = (data['voltage'] is int)
                    ? (data['voltage'] as int).toDouble()
                    : data['voltage'] as double;
                logger.info(
                    'Battery level received from device $deviceId: ${voltage}V');

                // Можно добавить сохранение значения в Device
                device.batteryVoltage = voltage;
              }
              break;
          }
        } catch (e, stackTrace) {
          logger.severe('Error processing message: $e\n$stackTrace');
        }
      },
      onDone: () {
        cleanupState();
      },
      onError: (error) {
        cleanupState();
        socket.sink.close();
      },
    );
  }

  Future<Response> setMatrixColors(
    String deviceId, {
    required String matrix1Color,
    required String matrix2Color,
    bool turnOn = true,
  }) async {
    if (!devices.containsKey(deviceId)) {
      return Response.notFound(
        jsonEncode({'status': 'error', 'message': 'Device not found'}),
        headers: {'content-type': 'application/json'},
      );
    }

    try {
      final device = devices[deviceId]!;
      final command = {
        'type': 'matrix_control',
        'matrix1': {
          'color': matrix1Color,
          'state': turnOn,
        },
        'matrix2': {
          'color': matrix2Color,
          'state': turnOn,
        }
      };

      device.socket.sink.add(jsonEncode(command));

      return Response.ok(
        jsonEncode(
            {'status': 'success', 'message': 'Command sent successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      logger.severe('Error sending command to device $deviceId: $e');
      return Response.internalServerError(
        body: jsonEncode(
            {'status': 'error', 'message': 'Failed to send command'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<void> start() async {
    if (_isRunning) {
      logger.info('Сервер уже запущен, повторный запуск не требуется');
      return;
    }

    try {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        print('${record.time}: ${record.level.name}: ${record.message}');
      });

      serverIp = await getLocalIP(subnet);
      logger.info('Server IP address: $serverIp');
      startInactivityCheck();

      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addMiddleware(_corsMiddleware)
          .addHandler(router);

      final server = await shelf_io.serve(handler, serverIp, port);
      _isRunning = true;
      logger
          .info(
          'Server started on http://${server.address.host}:${server.port}');
    } catch (e) {
      logger.severe('Ошибка при запуске сервера: $e');
      _isRunning = false;
      rethrow;
    }
  }

  Middleware get _corsMiddleware {
    return createMiddleware(
      requestHandler: (Request request) {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        return null;
      },
      responseHandler: (Response response) {
        return response.change(headers: {...response.headers, ..._corsHeaders});
      },
    );
  }

  final _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  };
}



// 1. Просто переносим весь код main() в этот класс

class ServerLauncher {
  static Future<void> launchInContext(BuildContext context) async {
    // --- Полностью сохраняем оригинальный код main() ---
    WidgetsFlutterBinding.ensureInitialized();
    AppLifecycleManager.init();

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.time}: ${record.level.name}: ${record.message}');
    });


    print('Экземпляров сервера до создания: ${ESP32Server._instanceCount}');
    final server = ESP32Server(subnet: '192.168.1');
    print('Экземпляров сервера после создания: ${ESP32Server._instanceCount}');

    handleAppTermination(server);

    await runZonedGuarded(
          () async {
        await server.start();
        // 2. Единственное изменение - используем Navigator вместо runApp
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MaterialApp(
              home: ESPControlApp(server: server),
            ),
          ),
        );
      },
          (error, stackTrace) {
        print('Необработанная ошибка: $error');
        print('Стек трассировки: $stackTrace');
        exit(1);
      },
    );
  }
}



/*void main() async {
  // Инициализация привязок Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация жизненного цикла приложения
  AppLifecycleManager.init();

  // Настройка логирования
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.time}: ${record.level.name}: ${record.message}');
  });

  print(
      'Количество экземпляров сервера перед созданием: ${ESP32Server._instanceCount}');

  // Создаем сервер с параметрами по умолчанию
  final server = ESP32Server(subnet: '192.168.1');

  print(
      'Количество экземпляров сервера после создания: ${ESP32Server._instanceCount}');

  // Обработка завершения приложения
  handleAppTermination(server);

  // Запуск в защищенной зоне с обработкой необработанных ошибок
  runZonedGuarded(
    () async {
      await server.start();
      runApp(ESPControlApp(server: server));
    },
    (error, stackTrace) {
      print('Необработанная ошибка: $error');
      print('Стек трассировки: $stackTrace');
      exit(1);
    },
  );
}*/

// Вынесенная функция обработки завершения приложения
void handleAppTermination(ESP32Server server) {
  // Обработка Ctrl+C (работает на всех платформах)
  ProcessSignal.sigint.watch().listen((signal) async {
    print('\nПолучен сигнал завершения, выполняется корректное закрытие...');
    // Закрываем все соединения
    for (var device in server.devices.values) {
      try {
        await device.socket.sink.close();
      } catch (e) {
        print('Ошибка закрытия соединения: $e');
      }
    }
    server.devices.clear();
    exit(0);
  });

  // Обработка SIGTERM только для POSIX систем (Linux/MacOS)
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((signal) async {
      print('Получен SIGTERM, выполняется завершение...');
      // Закрываем все соединения
      for (var device in server.devices.values) {
        try {
          await device.socket.sink.close();
        } catch (e) {
          print('Ошибка закрытия соединения: $e');
        }
      }
      server.devices.clear();
      exit(0);
    });
  }
}
