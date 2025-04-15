import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class DeviceCard extends StatefulWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        decoration: BoxDecoration(
          color: nsgtheme.colorTertiary.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              //color: Colors.lightGreen,
              margin: const EdgeInsets.only(left: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Устройство ID ', style: TextStyle(color: Color(0xFF1C1B1F), fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(widget.device.id,
                      overflow: TextOverflow.clip, style: TextStyle(color: nsgtheme.colorTertiary, fontSize: 12, fontWeight: FontWeight.w400)),
                  Text('ip = ${widget.device.address}', style: TextStyle(color: nsgtheme.colorTertiary, fontSize: 16, fontWeight: FontWeight.w400)),
                  if (widget.device.isVibrationDetected) const Text('ДАТЧИК УДАРА'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _lamp(widget.device.isRedOn, Colors.red),
                      _lamp(widget.device.isGreenOn, Colors.green),
                      _lamp(widget.device.isBlueOn, Colors.blue),
                    ],
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget _lamp(bool isOn, MaterialColor color) {
    var color2 = isOn ? color : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(width: 50, height: 50, color: color, child: Center(child: Container(width: 20, height: 20, color: color2))),
    );
  }
}
