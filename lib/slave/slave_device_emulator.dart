import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';


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

  ServerSocket? _tcpServer;
  final int _tcpPort = 5901; // порт для TCP-подключений
  final List<Socket> _connectedClients = [];

  Future<void> start() async {
    if (_isRunning) return;
    _uuid = _generateUuid();

    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _listenPort, reuseAddress: true);
    _udpSocket?.broadcastEnabled = true;
    _udpSocket?.listen(_handleUdpPacket);

    _tcpServer = await ServerSocket.bind(InternetAddress.anyIPv4, _tcpPort);
    _tcpServer?.listen(_handleTcpConnection);

    _isRunning = true;
    print('Slave device started on UDP port $_listenPort with UUID $_uuid');
  }

  void _handleTcpConnection(Socket client) {
    print('Client connected: ${client.remoteAddress.address}:${client.remotePort}');
    _connectedClients.add(client);

    // _onConnected(); // Вот здесь ты можешь обновлять матрицу

    client.listen(
          (data) {
        print('Received data: ${utf8.decode(data)}');
        // Тут можно будет потом добавить реакцию на команды
      },
      onDone: () {
        print('Client disconnected: ${client.remoteAddress.address}:${client.remotePort}');
        _connectedClients.remove(client);
      },
      onError: (error) {
        print('Client error: $error');
        _connectedClients.remove(client);
      },
    );
  }

  void stop() {
    _udpSocket?.close();
    _udpSocket = null;
    _tcpServer?.close();
    _tcpServer = null;
    _isRunning = false;
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
      'port': _tcpPort, // <<<< ОБЯЗАТЕЛЬНО добавь эту строчку ПОРТ
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

 /* void _onConnected() {
    // Здесь мы будем зажигать все лампочки
    _onUpdate?.call(
      SlaveDeviceState(
        ledMatrix: List.generate(8, (_) => List.filled(8, true)),
        ledRing: List.filled(12, true),
        isConnected: true,
      ),
    );
  } */
}
