import 'package:flutter/material.dart';

class LedMatrix extends StatelessWidget {
  final List<List<bool>> leds;
  final double ledSize;
  final Color activeColor;
  final Color inactiveColor;

  const LedMatrix({
    Key? key,
    required this.leds,
    this.ledSize = 30.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: leds[0].length,
        childAspectRatio: 1.0,
      ),
      itemCount: leds.length * leds[0].length,
      itemBuilder: (context, index) {
        int row = index ~/ leds[0].length;
        int col = index % leds[0].length;
        return Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: leds[row][col] ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}