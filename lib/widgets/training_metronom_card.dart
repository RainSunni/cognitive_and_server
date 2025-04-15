import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nsg_controls/nsg_controls.dart';

class TrainingMetronomCard extends StatefulWidget {
  final TrainingMetronom data;

  const TrainingMetronomCard({super.key, required this.data});

  @override
  State<TrainingMetronomCard> createState() => _TrainingMetronomCardState();
}

class _TrainingMetronomCardState extends State<TrainingMetronomCard> {
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
                    const Text('Метроном',
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 1,
                        style: TextStyle(color: Color(0xFF1C1B1F), fontSize: 16, fontWeight: FontWeight.w500)),
                    Text('Звуковой сигнал с интервалами',
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 1,
                        style: TextStyle(color: nsgtheme.colorTertiary, fontSize: 12, fontWeight: FontWeight.w400)),
                  ],
                ),
              )
            ],
          ));
    }
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
                        'lib/assets/svg/metronome.svg',
                        semanticsLabel: 'Метроном',
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
                        const Text('Метроном',
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(color: Color(0xFF1C1B1F), fontSize: 16, fontWeight: FontWeight.w500)),
                        Text('Звуковой сигнал с интервалами',
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(color: nsgtheme.colorTertiary, fontSize: 12, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ],
              )),
          _getFieldInfo('Начальное к-во ударов вминуту', '${widget.data.initialBpm} ударов в минуту'),
          _getFieldInfo('Конечное к-во ударов вминуту', '${widget.data.targetBpm} ударов в минуту'),
          _getFieldInfo('Процент изменения', '${widget.data.intervalProcent}%'),
          _getFieldInfo('Время перехода (сек.)', '${widget.data.delayTime} секунд'),
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
