import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nsg_controls/nsg_controls.dart';

class TrainingMathCard extends StatefulWidget {
  final TrainingMath data;

  const TrainingMathCard({super.key, required this.data});

  @override
  State<TrainingMathCard> createState() => _TrainingMathCardState();
}

class _TrainingMathCardState extends State<TrainingMathCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Container(
          height: 68,
          decoration: BoxDecoration(
            color: nsgtheme.colorTertiary.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Container(
                    decoration: BoxDecoration(
                      color: nsgtheme.colorPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add,
                      color: nsgtheme.colorBase.c100,
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(left: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Математическое задание', style: TextStyle(color: Color(0xFF1C1B1F), fontSize: 16, fontWeight: FontWeight.w500)),
                    Text('Математические операции', style: TextStyle(color: nsgtheme.colorTertiary, fontSize: 12, fontWeight: FontWeight.w400)),
                  ],
                ),
              )
            ],
          ));
    }
    List<String> operations = [];
    if (widget.data.useAddition) operations.add('сложение');
    if (widget.data.useSubtraction) operations.add('вычитание');
    if (widget.data.useMultiplication) operations.add('умножение');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A91AD).withAlpha(60),
            spreadRadius: 0,
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FD),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: SvgPicture.asset(
                        'lib/assets/svg/math.svg',
                        semanticsLabel: 'Математика',
                        fit: BoxFit.contain,
                        width: 33,
                        height: 33,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Математическое задание', style: TextStyle(color: Color(0xFF1C1B1F), fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(
                          height: 4,
                        ),
                        Text('Математические операции', style: TextStyle(color: nsgtheme.colorTertiary, fontSize: 12, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ],
              )),
          _getFieldInfo('Минимальное число', widget.data.minNumber.toString()),
          _getFieldInfo('Максимальное число', widget.data.maxNumber.toString()),
          //_getFieldInfo('Время ожидания (сек.)', widget.data.delayTime.toString()),
          _getFieldInfo('Операции', operations.join(', ')),
        ],
      ),
    );
  }

  Widget _getFieldInfo(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(color: Color(0xFF1C1B1F), fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(color: nsgtheme.colorTertiary, fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
