import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'server_main.dart';

// Модель устройства для UI
class ESPDevice {
  final String guid;
  final String ipAddress;
  final bool connected;
  final DateTime lastActivity;
  final bool matrix1State;
  final bool matrix2State;
  final int vibrationCount;
  final double? batteryVoltage;

  ESPDevice({
    required this.guid,
    required this.ipAddress,
    required this.connected,
    required this.lastActivity,
    this.matrix1State = false,
    this.matrix2State = false,
    this.vibrationCount = 0,
    this.batteryVoltage,
  });

  ESPDevice copyWith({
    bool? matrix1State,
    bool? matrix2State,
  }) {
    return ESPDevice(
      guid: guid,
      ipAddress: ipAddress,
      connected: connected,
      lastActivity: lastActivity,
      matrix1State: matrix1State ?? this.matrix1State,
      matrix2State: matrix2State ?? this.matrix2State,
      vibrationCount: vibrationCount,
      batteryVoltage: batteryVoltage,
    );
  }
}

class ESPControlApp extends StatelessWidget {
  final ESP32Server server;

  const ESPControlApp({required this.server, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: ESPControlHome(server: server),
    );
  }
}

class ESPControlHome extends StatefulWidget {
  final ESP32Server server;

  const ESPControlHome({required this.server, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ESPControlHomeState createState() => _ESPControlHomeState();
}

class _ESPControlHomeState extends State<ESPControlHome> {
  List<ESPDevice> devices = [];
  String? alertMessage;
  bool showAlert = false;
  Timer? statusCheckTimer;
  Timer? _uiUpdateTimer;

  @override
  void initState() {
    super.initState();
    startStatusCheck();
    // Добавляем таймер для обновления UI каждую секунду
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Обновляем UI для отображения времени
      });
    });
  }

  void showAlertMessage(String message, {bool isError = false}) {
    setState(() {
      alertMessage = message;
      showAlert = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showAlert = false;
        });
      }
    });
  }

  void startStatusCheck() {
    statusCheckTimer?.cancel();
    statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateDevicesList();
    });
  }

  void updateDevicesList() {
    setState(() {
      devices = widget.server.devices.values
          .map((device) => ESPDevice(
                guid: device.guid,
                ipAddress: device.ipAddress,
                connected: true,
                lastActivity: device.lastActivity,
                matrix1State: device.matrixState,
                matrix2State: device.matrixState,
                vibrationCount: device.vibrationCount,
                batteryVoltage: device.batteryVoltage,
              ))
          .toList();
    });
  }

  Future<void> handleScanNetwork() async {
    try {
      showAlertMessage('Starting network scan...');
      await widget.server.scanNetwork();
      showAlertMessage('Network scan completed');
      updateDevicesList();
    } catch (e) {
      showAlertMessage('Error scanning network: $e', isError: true);
    }
  }

  Future<void> handleDisconnectDevices() async {
    try {
      showAlertMessage('Clearing devices...');
      await widget.server.disconnectDevices();
      showAlertMessage('Devices cleared');
      updateDevicesList();
    } catch (e) {
      showAlertMessage('Error clearing devices: $e', isError: true);
    }
  }

  Future<void> handleClearDevices() async {
    try {
      showAlertMessage('Clearing devices...');
      await widget.server.clearKnownDevices();
      showAlertMessage('Devices cleared');
      updateDevicesList();
    } catch (e) {
      showAlertMessage('Error clearing devices: $e', isError: true);
    }
  }

  Future<void> handleConnectDevices() async {
    try {
      showAlertMessage('Connecting to known devices...');
      await widget.server.connectKnownDevices();
      showAlertMessage('Connected to devices');
      updateDevicesList();
    } catch (e) {
      showAlertMessage('Error connecting to devices: $e', isError: true);
    }
  }

  Future<void> handleMatrixControl(
      String deviceId, String matrix1Color, String matrix2Color) async {
    if (!widget.server.devices.containsKey(deviceId)) {
      showAlertMessage('Device not found', isError: true);
      return;
    }

    try {
      final device = widget.server.devices[deviceId]!;
      final command = {
        'type': 'matrix_control',
        'matrix1': {'color': matrix1Color, 'state': true},
        'matrix2': {'color': matrix2Color, 'state': true}
      };

      device.socket.sink.add(jsonEncode(command));
      showAlertMessage('Matrix control command sent');
    } catch (e) {
      showAlertMessage('Error controlling matrix: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ESP Control'),
            Text(
              'Server: ${widget.server.serverIp}:${widget.server.port}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Tooltip(
                            message: 'Search',
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Colors.blue,
                              onPressed: handleScanNetwork,
                              child:
                                  const Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                          Tooltip(
                            message: 'Disconnect',
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor:
                                  const Color.fromARGB(255, 247, 148, 0),
                              onPressed: handleDisconnectDevices,
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.white),
                            ),
                          ),
                          Tooltip(
                            message: 'Connect',
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Colors.green,
                              onPressed: handleConnectDevices,
                              child: const Icon(Icons.wifi_tethering,
                                  color: Colors.white),
                            ),
                          ),
                          Tooltip(
                            message: 'Clear',
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Colors.red,
                              onPressed: handleClearDevices,
                              child: const Icon(Icons.delete_forever,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: devices.isEmpty
                    ? const Center(
                        child: Text(
                          'No devices found.\nTry scanning the network.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          final timeSinceLastActivity =
                              DateTime.now().difference(device.lastActivity);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Device ${device.guid}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: device.connected
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('IP: ${device.ipAddress}'),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          'Vibrations: ${device.vibrationCount}'),
                                      Text(
                                        'Last activity: ${_formatDuration(timeSinceLastActivity)}',
                                        style: TextStyle(
                                          color:
                                              timeSinceLastActivity.inMinutes >=
                                                      4
                                                  ? Colors.red
                                                  : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (device.batteryVoltage != null)
                                    Text('Battery: ${device.batteryVoltage}V'),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ToggleButtons(
                                        isSelected: [device.matrix1State],
                                        onPressed: (int index) {
                                          handleMatrixControl(
                                            device.guid,
                                            device.matrix1State
                                                ? 'black'
                                                : 'green',
                                            device.matrix2State
                                                ? 'green'
                                                : 'black',
                                          );
                                        },
                                        children: const [
                                          // Icon(Icons.lightbulb_outline),
                                          Icon(Icons.square),
                                        ],
                                      ),
                                      ToggleButtons(
                                        isSelected: [device.matrix2State],
                                        onPressed: (int index) {
                                          handleMatrixControl(
                                            device.guid,
                                            device.matrix1State
                                                ? 'green'
                                                : 'black',
                                            device.matrix2State
                                                ? 'black'
                                                : 'green',
                                          );
                                        },
                                        children: const [
                                          // Icon(Icons.lightbulb_outline),
                                          Icon(Icons.circle),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (showAlert)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: alertMessage!.startsWith('Error')
                      ? Colors.red
                      : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alertMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s ago';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ago';
    }
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    statusCheckTimer?.cancel();
    super.dispose();
  }
}
