import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

// логика эмулятора слейв режима

class SlaveDeviceEmulator {
  static final SlaveDeviceEmulator _instance = SlaveDeviceEmulator._internal();

  factory SlaveDeviceEmulator() {
    return _instance;
  }

  SlaveDeviceEmulator._internal();

  RawDatagramSocket? _udpSocket;
  bool _isRunning = false;
  final int _listenPort = 5900; // Порт на который приходит сканирование
  final String _deviceName = "Slave Device";
  final String _deviceType = "light"; // Имя и тип устройства

  late String _uuid; // уникальный id устройства

  final int _tcpPort = 5901; // порт для WebSocket-подключений

  Future<void> start() async {
    if (_isRunning) return;
    _uuid = _generateUuid();

    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _listenPort, reuseAddress: true);
    _udpSocket?.broadcastEnabled = true;
    _udpSocket?.listen(_handleUdpPacket);

    // WebSocket сервер
    final handler = webSocketHandler((WebSocket socket) {
      print('К серверу подключился WebSocket клиент');

      // Отправка identify при подключении
      socket.add(jsonEncode({
        'type': 'identify',
        'deviceId': _uuid,
        'port': _tcpPort,
      }));

      socket.listen(
            (data) {
          print('Получено по WebSocket: $data');
          // Здесь можно обработать команды, обновить интерфейс и т.д.
        },
        onDone: () {
          print('Клиент отключился');
        },
        onError: (error) {
          print('Ошибка WebSocket: $error');
        },
      );
    });

    final server = await io.serve(handler, InternetAddress.anyIPv4, _tcpPort);
    print('Slave WebSocket server started on ws://${server.address.host}:$_tcpPort');

    _isRunning = true;
    print('Slave device started on UDP port $_listenPort with UUID $_uuid');
  }

  void stop() {
    _udpSocket?.close();
    _udpSocket = null;
    _isRunning = false;
    // WebSocket сервер shelf автоматически закрывается с приложением
  }

  void _handleUdpPacket(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagram = _udpSocket?.receive();
      if (datagram == null) return;

      final data = utf8.decode(datagram.data);
      print('Received UDP packet: $data');

      try {
        final Map<String, dynamic> message = json.decode(data);

        if (message['cmd'] == 'scan') {
          _sendInfoResponse(datagram.address, datagram.port);
        }
      } catch (e) {
        print('Error parsing UDP message: $e');
      }
    }
  }

  void _sendInfoResponse(InternetAddress address, int port) {
    final response = {
      'cmd': 'info',
      'type': 'device',
      'deviceType': _deviceType,
      'deviceName': _deviceName,
      'uuid': _uuid,
      'port': _tcpPort, // ВАЖНО: отправляем порт WebSocket
    };

    final data = utf8.encode(json.encode(response));
    _udpSocket?.send(data, address, port);

    print('Sent device info to ${address.address}:$port');
  }

  String _generateUuid() {
    final random = Random();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
  }
}

