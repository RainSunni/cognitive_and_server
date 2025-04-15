import 'dart:ui';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_grid.dart';

class ColorListPicker extends StatefulWidget {
  const ColorListPicker({
    Key? key,
    this.initColors,
    this.allowSameColors = false,
    this.onChange,
  }) : super(key: key);

  final List<Color>? initColors;

  final bool allowSameColors;
  final Function(List<Color> colors)? onChange;

  @override
  State<ColorListPicker> createState() => _ColorListPickerState();
}

class _ColorListPickerState extends State<ColorListPicker> {
  late List<Color> selectedColors;
  List<Color> allowedColors = [];

  @override
  void initState() {
    super.initState();
    allowedColors = [
      const Color(0xFFffffff),
      const Color(0xFF000000),
      const Color.fromARGB(255, 255, 17, 0),
      const Color.fromARGB(255, 0, 4, 255),
      const Color.fromARGB(255, 255, 230, 0),
      const Color.fromARGB(255, 0, 255, 8),
      const Color(0xFFff9800),
      const Color.fromARGB(255, 217, 0, 255),
      const Color.fromARGB(255, 145, 51, 18),
      const Color.fromARGB(255, 0, 225, 255)
    ];
    if (widget.initColors != null) {
      selectedColors = widget.initColors!;
    } else {
      selectedColors = [];
    }
  }

  // void _showColorPickerDialog() {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return Center(
  //           child: CircleColorPicker(
  //             size: const Size(240, 240),
  //             strokeWidth: 4,
  //             thumbSize: 36,
  //             onEnded: (color) {
  //               _addColor(color);
  //             },
  //           ),
  //         );
  //       });
  // }

  void _addColor(Color color) {
    if (!widget.allowSameColors && selectedColors.any((x) => x == color)) {
      return;
    }
    setState(() {
      selectedColors.add(color);
    });
    if (widget.onChange != null) widget.onChange!(selectedColors);
  }

  void _removeColor(int index) {
    setState(() {
      selectedColors.removeAt(index);
    });
    if (widget.onChange != null) widget.onChange!(selectedColors);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 15),
          child: Text(
            'Выбранные цвета',
            style: TextStyle(fontSize: nsgtheme.sizeL),
          ),
        ),
        showSelectedColors(),
        showAllowedColors(),
      ],
    );
  }

/* ---------------------------------------------------------------- Выбранные цвета --------------------------------------------------------------- */
  Widget showSelectedColors() {
    List<Widget> list = [];
    if (selectedColors.isEmpty) {
      return Column(
        children: [
          Text(
            'Добавьте цвета в упражнение',
            style: TextStyle(color: nsgtheme.colorNeutral),
          ),
          Icon(
            Icons.arrow_downward_sharp,
            size: 32,
            color: nsgtheme.colorNeutral,
          )
        ],
      );
    } else {
      for (var (index, color) in selectedColors.indexed) {
        list.add(InkWell(
          onTap: () => _removeColor(index),
          child: ColoredGradBox(
            color: color,
          ),
        ));
      }
    }

    return NsgGrid(centered: false, hGap: 5, vGap: 5, crossAxisCount: 5, children: list);
  }

/* -------------------------------------------------------- Доступные для добавления цвета -------------------------------------------------------- */
  Widget showAllowedColors() {
    List<Widget> list = [];
    for (var color in allowedColors) {
      if (selectedColors.firstWhereOrNull((element) => element == color) == null) {
        list.add(InkWell(
          onTap: () {
            _addColor(color);
          },
          child: ColoredGradBox(color: color),
        ));
      }
    }
    list.add(InkWell(
      onTap: () {
        colorPicker(
          context: context,
          onColorChange: (color) {
            allowedColors.add(color);
            setState(() {});
          },
          color: Colors.red,
        );
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: nsgtheme.colorNeutral),
          ),
          child: Center(
              child: Icon(
            Icons.add,
            size: 32,
            color: nsgtheme.colorNeutral,
          )),
        ),
      ),
    ));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 15),
          child: Text(
            'Нажмите на нужный цвет',
            style: TextStyle(fontSize: nsgtheme.sizeL),
          ),
        ),
        NsgGrid(
          centered: false,
          hGap: 5,
          vGap: 5,
          crossAxisCount: 5,
          children: list,
        ),
      ],
    );
  }
}

/* -------------------------------------------------------- Цветной квадратик с градиентом -------------------------------------------------------- */
class ColoredGradBox extends StatelessWidget {
  const ColoredGradBox({
    super.key,
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: darken(darken(darken(color)))),
          gradient: LinearGradient(
              colors: [darken(darken(color)), darken(color), color, color, darken(darken(color))],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [.1, .3, .4, .7, 1]),
        ),
      ),
    );
  }
}

Future colorPicker({required BuildContext context, required Function(Color) onColorChange, required Color color}) async {
  if (context.mounted) {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: SimpleDialog(
            backgroundColor: nsgtheme.colorSecondary,
            insetPadding: const EdgeInsets.all(10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            children: [
              StatefulBuilder(builder: (context, setstate) {
                return Column(
                  children: [
                    ColorPicker(
                        // Use the screenPickerColor as start color.
                        color: color,
                        pickersEnabled: const {ColorPickerType.accent: false, ColorPickerType.custom: false},
                        // Update the screenPickerColor using the callback.
                        onColorChanged: (Color newColor) {
                          color = newColor;
                          //   onColorChange(color);
                          setstate(() {});
                        },
                        padding: const EdgeInsets.all(0),
                        width: 40,
                        height: 40,
                        spacing: 5,
                        runSpacing: 5,
                        borderRadius: 5,
                        heading: Text(
                          'Выберите цвет',
                          style: TextStyle(color: nsgtheme.colorBase),
                        ),
                        subheading: Text(
                          'Выберите оттенок цвета',
                          style: TextStyle(color: nsgtheme.colorBase),
                        )),
                    // Text(
                    //   'Яркость цвета',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(color: nsgtheme.colorTertiary.b100),
                    // ),
                    // colorBrightness(
                    //     color: color,
                    //     onSelect: (selColor) {
                    //       onColorChange(Colors.transparent);
                    //       color = selColor;
                    //       onColorChange(color);
                    //       setstate(() {});
                    //     }),
                    // Text(
                    //   'Прозрачность цвета',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(color: nsgtheme.colorTertiary.b100),
                    // ),
                    // colorTransparency(
                    //     color: color,
                    //     onSelect: (opacity) {
                    //       onColorChange(Colors.transparent);
                    //       color = color.withOpacity(opacity / 20);
                    //       onColorChange(color);
                    //       setstate(() {});
                    //     }),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NsgButton(
                          width: 130,
                          text: 'Отмена',
                          color: nsgtheme.colorTertiary.c100,
                          backColor: nsgtheme.colorTertiary,
                          margin: const EdgeInsets.only(top: 10),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 10),
                        NsgButton(
                          width: 130,
                          text: 'Применить',
                          margin: const EdgeInsets.only(top: 10),
                          onPressed: () {
                            onColorChange(color);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
