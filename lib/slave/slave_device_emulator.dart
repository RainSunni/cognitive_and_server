import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';

class SlaveDeviceEmulator {
  static const int _port = 5000;
  static const String _broadcastAddress = '255.255.255.255';
  static const String _discoveryMessage = 'COG_DEVICE_DISCOVERY';

  RawDatagramSocket? _udpSocket;
  Timer? _broadcastTimer;
  String _deviceId = 'Slave-${Random().nextInt(9000) + 1000}';
  bool _isRunning = false;
  final ValueChanged<String>? onLog;

  SlaveDeviceEmulator({this.onLog});

  Future<void> start() async {
    if (_isRunning) return;

    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port);
      _udpSocket!.broadcastEnabled = true;

      _startBroadcasting();
      _startListening();

      _isRunning = true;
      onLog?.call('Slave mode started. Device ID: $_deviceId');
    } catch (e) {
      onLog?.call('Error starting slave mode: $e');
      rethrow;
    }
  }

  void _startBroadcasting() {
    _broadcastTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      try {
        final interfaces = await NetworkInterface.list();

        for (var interface in interfaces) {
          // Пропускаем не-WiFi интерфейсы
          if (!_isWifiInterface(interface.name)) continue;

          for (var address in interface.addresses) {
            if (address.type != InternetAddressType.IPv4 || address.isLoopback) continue;

            final message = '$_discoveryMessage:$_deviceId:${address.address}:$_port';
            _sendBroadcast(message, address);
          }
        }
      } catch (e) {
        onLog?.call('Broadcast error: $e');
      }
    });
  }

  bool _isWifiInterface(String name) {
    return name.toLowerCase().contains('wlan') ||
        name.toLowerCase().contains('wifi') ||
        name.toLowerCase().contains('ap');
  }

  void _sendBroadcast(String message, InternetAddress localAddress) {
    try {
      _udpSocket?.send(
        utf8.encode(message),
        InternetAddress(_broadcastAddress),
        _port,
      );
      onLog?.call('Broadcast sent: $message from ${localAddress.address}');
    } catch (e) {
      onLog?.call('Send error: $e');
    }
  }

  void _startListening() {
    _udpSocket?.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = _udpSocket?.receive();
        if (datagram != null) {
          final message = utf8.decode(datagram.data);
          onLog?.call('Received: $message from ${datagram.address.address}');
          _handleIncomingMessage(message, datagram.address);
        }
      }
    });
  }

  void _handleIncomingMessage(String message, InternetAddress sender) {
    if (message.startsWith('COG_SERVER_DISCOVERY')) {
      final response = 'COG_DEVICE_RESPONSE:$_deviceId';
      _udpSocket?.send(
        utf8.encode(response),
        sender,
        _port,
      );
      onLog?.call('Responded to server discovery');
    }
  }

  void stop() {
    _broadcastTimer?.cancel();
    _udpSocket?.close();
    _isRunning = false;
    onLog?.call('Slave mode stopped');
  }

  Future<List<InternetAddress>> getNetworkInterfaces() async {
    final interfaces = await NetworkInterface.list();
    final addresses = <InternetAddress>[];

    for (var interface in interfaces) {
      if (!_isWifiInterface(interface.name)) continue;

      for (var address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
          addresses.add(address);
        }
      }
    }

    return addresses;
  }
}