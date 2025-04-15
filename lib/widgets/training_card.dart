import 'package:cognitive_training/model/enums/e_metronome_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nsg_controls/nsg_controls.dart';

import '../model/training.dart';

class TrainingCard extends StatelessWidget {
  const TrainingCard({
    super.key,
    required this.item,
  });

  final Training item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A91AD).withAlpha(60),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: trainingInfo(item: item),
    );
  }
}

trainingInfo({required Training item}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: nsgtheme.sizeS)),
            ),
          ],
        ),
      ),
      if (item.comment.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(item.comment, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeXS)),
              ),
            ],
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                children: [
                  Text('Длит: ${item.useDurationMinutes ? item.durationMinutes : item.durationSeconds}${item.useDurationMinutes ? ' мин' : ' сек'} , ',
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeXS)),
                  Text('Нач: ${item.audioCountdownToStart} , ', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeXS)),
                  if (item.audioCountdownToFinish != 0)
                    Text('Заверш: ${item.audioCountdownToFinish} , ',
                        maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeXS)),
                  if (item.beeperInterval != 0)
                    Text('Бипер: ${item.beeperInterval}', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeXS))
                ],
              ),
            ),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.math.isNotEmpty) showMath(item: item),
          if (item.colors.isNotEmpty) showColors(item: item),
          if (item.metronom.isNotEmpty) showMetronome(item: item),
        ],
      ),
    ],
  );
}

Widget showMath({required Training item}) {
  List<String> operations = [];
  if (item.math.useAddition) operations.add('слож');
  if (item.math.useSubtraction) operations.add('вычит');
  if (item.math.useMultiplication) operations.add('умнож');
  return Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        SvgPicture.asset(
          'lib/assets/svg/math.svg',
          semanticsLabel: 'Математика',
          fit: BoxFit.contain,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(nsgtheme.colorPrimary, BlendMode.srcIn),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Мин: ${item.math.minNumber}',
                    style: TextStyle(fontSize: nsgtheme.sizeXS),
                  ),
                  Text(' , ', style: TextStyle(fontSize: nsgtheme.sizeXS)),
                  Text('Макс: ${item.math.minNumber}', style: TextStyle(fontSize: nsgtheme.sizeXS)),
                ],
              ),
              Text(operations.join(' , '), style: TextStyle(fontSize: nsgtheme.sizeXS)),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget showMetronome({required Training item}) {
  return Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        SvgPicture.asset(
          'lib/assets/svg/metronome.svg',
          semanticsLabel: 'Метроном',
          fit: BoxFit.contain,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(nsgtheme.colorPrimary, BlendMode.srcIn),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Тип: ${item.metronom.metronomeMode.name}',
                style: TextStyle(fontSize: nsgtheme.sizeXS),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  Text('Нач: ${item.metronom.initialBpm}', style: TextStyle(fontSize: nsgtheme.sizeXS)),
                  if (item.metronom.metronomeMode == EMetronomeMode.linear) Text(' , ', style: TextStyle(fontSize: nsgtheme.sizeXS)),
                  if (item.metronom.metronomeMode == EMetronomeMode.linear)
                    Text('Фин: ${item.metronom.targetBpm}', style: TextStyle(fontSize: nsgtheme.sizeXS)),
                ],
              ),
              const SizedBox(width: 10),
              if (item.metronom.metronomeMode == EMetronomeMode.percentage)
                Row(
                  children: [
                    Text('Время: ${item.metronom.delayTime}', style: TextStyle(fontSize: nsgtheme.sizeXS)),
                    Text(' , ', style: TextStyle(fontSize: nsgtheme.sizeXS)),
                    Text('Проц: ${item.metronom.delayTime}', style: TextStyle(fontSize: nsgtheme.sizeXS)),
                  ],
                ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget showColors({required Training item}) {
  List<Widget> list = [];
  for (var hexColor in item.colors.colors.split(',')) {
    list.add(Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: stringToColor(hexColor), borderRadius: BorderRadius.circular(2)),
    ));
  }
  return Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        SvgPicture.asset(
          'lib/assets/svg/color.svg',
          semanticsLabel: 'Цвета',
          fit: BoxFit.contain,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(nsgtheme.colorPrimary, BlendMode.srcIn),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Wrap(
              runSpacing: 2,
              spacing: 2,
              children: list,
            ),
          ),
        ),
      ],
    ),
  );
}
