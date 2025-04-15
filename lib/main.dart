import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/formfields/nsg_field_type.dart';
import 'package:nsg_controls/formfields/nsg_switch_horizontal.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_simple_progress_bar.dart';
import 'package:nsg_data/nsg_data.dart';

import 'app_pages.dart';

void main() {
//  Color colorPrimary = const Color(0xFF4D72F6);
  Color colorPrimary = const Color(0xFF5C8F27);
  Color colorSecondary = const Color.fromARGB(255, 143, 133, 39);
  Color colorTertiary = const Color.fromARGB(255, 184, 184, 184);
  Color colorNeutral = const Color(0xFF7D8D99);

  ControlOptions newinstance = ControlOptions(
    nsgButtonMargin: EdgeInsets.zero,
    borderRadius: 10,
    //

    nsgSwitchHorizontalStyle: NsgSwitchHorizontalStyle(
      trackColor: const Color(0xFFC2C5D7),
      trackActiveColor: colorPrimary,
      thumbColor: Colors.white,
      thumbActiveColor: Colors.white,
      textStyle: TextStyle(fontSize: nsgtheme.sizeL, color: const Color(0xFF1C1B1F)),
      textActiveStyle: TextStyle(fontSize: nsgtheme.sizeL, color: const Color(0xFF1C1B1F)),
      thumbHeight: 14,
      thumbWidth: 14,
      trackWidth: 48,
      trackHeight: 24,
      thumbBorderRadius: BorderRadius.circular(24),
      trackBorderRadius: BorderRadius.circular(32),
      thumbMargin: const EdgeInsets.all(4),
    ),

    colorPrimary: colorPrimary,
    colorMain: colorPrimary,
    colorSecondary: colorSecondary,
    colorTertiary: colorTertiary,
    colorNeutral: colorNeutral,
    gradients: {
      'back': [const Color.fromARGB(255, 237, 255, 33), Colors.white]
    },
    //colorNeutralSf: const Color.fromARGB(82, 230, 225, 229),
    colorSuccess: const Color.fromARGB(255, 0, 129, 43), //меняли const Color.fromARGB(255, 31, 138, 75),
    colorWarning: const Color.fromARGB(255, 237, 255, 33),
    colorError: const Color.fromARGB(255, 255, 83, 83),
    colorOverlay: const Color.fromARGB(122, 28, 27, 31),
    colorBase: const Color.fromARGB(255, 28, 27, 31),
    //colorSf: const Color.fromARGB(255, 255, 255, 255),

    colorMainText: const Color(0xFFFFFFFF),
    // colorMainBack: const Color(0xFF9FADEB),
    colorGrey: const Color(0xFF9FADEB),

    tableHeaderColor: darken(const Color.fromARGB(255, 208, 188, 255)),
    tableCellBackColor: const Color.fromARGB(255, 28, 27, 31),
    tableHeaderLinesColor: const Color.fromARGB(255, 208, 188, 255),
    nsgInputMargin: const EdgeInsets.only(bottom: 10),
    nsgInputFilled: true,

    sizeH4: 22,

    nsgInputColorLabel: const Color(0xFF7D8D99),
    nsgInputColorFilled: Colors.white,
    nsgInputBorderColor: const Color(0xFF7D8D99),
    nsgInputBorderActiveColor: const Color(0xFF7D8D99),
    nsgInputOutlineBorderType: TextFormFieldType.outlineInputBorder,
    nsgInputHintAlwaysOnTop: true,
    nsginputCloseIconColor: const Color.fromRGBO(125, 141, 153, 1),
    nsginputCloseIconColorHover: const Color.fromRGBO(125, 141, 153, 1),
    nsgInputContentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
  );

  ControlOptions.instance = newinstance;

  NsgBaseController.getDefaultProgressIndicator = (() => const Padding(
        padding: EdgeInsets.all(30),
        child: NsgSimpleProgressBar(),
      ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NsgDataControllerMode.defaultDataControllerMode = const NsgDataControllerMode(storageType: NsgDataStorageType.local);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.black, // navigation bar color
      statusBarIconBrightness: Brightness.dark, // status bar icons' color
      systemNavigationBarIconBrightness: Brightness.dark, //navigation bar icons' color
    ));
    return GetMaterialApp(
      textDirection: TextDirection.ltr,
      defaultTransition: Transition.rightToLeftWithFade,
      title: 'Cogtitive trainings',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 14.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.20,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.20,
          ),
          displayLarge: TextStyle(
            fontSize: 20.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
          displayMedium: TextStyle(
            fontSize: 18.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            height: 1.40,
            letterSpacing: 1.0,
          ),
          displaySmall: TextStyle(
            fontSize: 18.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.normal,
          ),
          headlineMedium: TextStyle(
            fontSize: 14.0,
            color: ControlOptions.instance.colorText,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.normal,
          ),
          labelLarge: const TextStyle(
            fontSize: 14.0,
            color: Color.fromRGBO(0, 0, 0, 1),
            fontFamily: 'Roboto',
            fontWeight: FontWeight.normal,
            height: 1.40,
            letterSpacing: 1.0,
          ),
          bodySmall: const TextStyle(
            fontSize: 14.0,
            color: Color.fromRGBO(33, 32, 30, 1),
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ru'),
    );
  }
}
