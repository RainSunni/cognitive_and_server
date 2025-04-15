import 'package:cognitive_training/model/data_controller_model.dart';
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

class TrainingSeriesCard extends StatelessWidget {
  const TrainingSeriesCard({
    super.key,
    required this.item,
  });

  final TrainingSeries item;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: nsgtheme.sizeM)),
                ),
              ],
            ),
          ),
          if (item.comment.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(item.comment,
                      maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorSecondary)),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text('Упражнений: ${item.table.rows.length}',
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorSecondary)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text('Время: ${showSeriesTotalTime()} мин',
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorSecondary)),
                ),
              ],
            ),
          ),
          // if (item.comment.isNotEmpty)
          //   Padding(
          //     padding: const EdgeInsets.only(bottom: 5),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       children: [
          //         Flexible(
          //           child: Text(item.comment, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeXS)),
          //         ),
          //       ],
          //     ),
          //   ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 5),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       Expanded(
          //         child: Wrap(
          //           children: [
          //             Text('Длит: ${item.durationSeconds} , ', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeXS)),
          //             Text('Нач: ${item.audioCountdownToStart} , ', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeXS)),
          //             if (item.audioCountdownToFinish != 0)
          //               Text('Заверш: ${item.audioCountdownToFinish} , ',
          //                   maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeXS)),
          //             if (item.beeperInterval != 0)
          //               Text('Бипер: ${item.beeperInterval}', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: nsgtheme.sizeXS))
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     if (item.math.isNotEmpty) showMath(),
          //     if (item.colors.isNotEmpty) showColors(),
          //     if (item.metronom.isNotEmpty) showMetronome(),
          //   ],
          // ),
        ],
      ),
    );
  }

  showSeriesTotalTime() {
    double totalMinutes = 0;
    for (var row in item.table.rows) {
      totalMinutes += row.training.durationMinutes + row.training.durationSeconds / 60;
      totalMinutes += row.pauseSeconds / 60;
    }
    return totalMinutes.floor();
  }
}
