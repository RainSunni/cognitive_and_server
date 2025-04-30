import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'slave_device_emulator.dart';
import 'widgets/led_matrix.dart';
import 'widgets/led_ring.dart';

class SlaveDeviceScreen extends StatefulWidget {
  @override
  _SlaveDeviceScreenState createState() => _SlaveDeviceScreenState();
}

class _SlaveDeviceScreenState extends State<SlaveDeviceScreen> {
  late SlaveDeviceEmulator _emulator;
  bool _isVisible = false;
  List<List<bool>> _ledMatrix = List.generate(8, (_) => List.filled(8, false));
  List<bool> _ledRing = List.filled(12, false);
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _emulator = SlaveDeviceEmulator();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slave Device Mode'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('About Slave Mode'),
                  content: Text(
                    'In this mode, your phone emulates a cognitive training device. '
                        'Other devices can discover and connect to it.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Enable Slave Mode'),
                      subtitle: Text(
                        _isVisible
                            ? 'Device is discoverable'
                            : 'Device is hidden',
                      ),
                      value: _isVisible,
                      onChanged: (value) {
                        setState(() {
                          _isVisible = value;
                          if (_isVisible) {
                            _emulator.start();
                          } else {
                            _emulator..stop();
                          }
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Device Preview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text('LED Matrix'),
                          SizedBox(height: 10),
                          Container(
                            width: 250,
                            height: 250,
                            child: LedMatrix(leds: _ledMatrix),
                          ),
                          SizedBox(height: 20),
                          Text('LED Ring'),
                          SizedBox(height: 10),
                          LedRing(leds: _ledRing),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Connection Logs',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Text(
                            _logs[index],
                            style: TextStyle(fontFamily: 'monospace'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}