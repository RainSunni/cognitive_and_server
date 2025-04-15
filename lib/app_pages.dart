import 'package:cognitive_training/pages/device/device_connect_page.dart';
import 'package:cognitive_training/pages/device/device_slave_page.dart';
import 'package:cognitive_training/pages/training/training_list_page.dart';
import 'package:get/get.dart';

import 'pages/device/device_binding.dart';
import 'pages/device/device_page.dart';
import 'pages/training/training_binding.dart';
import 'pages/training/training_edit_page.dart';
import 'pages/training_series/training_series_edit_page.dart';
import 'pages/training_series/training_series_list_page.dart';
import 'pages/training_series/training_series_screen_page.dart';
import 'splash/splash_binding.dart';
import 'splash/splash_page.dart';
import 'start_page.dart';

class AppPages {
  static const initial = Routes.splashPage;

  static final List<GetPage> routes = [
    GetPage(
      name: Routes.splashPage,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.mainPage,
      page: () => const StartPage(),
      //binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.trainingListPage,
      page: () => const TrainingListPage(),
      binding: TrainingBinding(),
    ),
    GetPage(
      name: Routes.trainingSeriesListPage,
      page: () => const TrainingSeriesListPage(),
      binding: TrainingBinding(),
    ),
    GetPage(
      name: Routes.trainingEditPage,
      page: () => const TrainingEditPage(),
      binding: TrainingBinding(),
    ),
    GetPage(
      name: Routes.trainingSeriesEditPage,
      page: () => const TrainingSeriesEditPage(),
      binding: TrainingBinding(),
    ),
    GetPage(
      name: Routes.trainingSeriesScreenPage,
      page: () => const TrainingSeriesScreenPage(),
      binding: TrainingBinding(),
    ),
    GetPage(
      name: Routes.deviceConnectPage,
      page: () => const DeviceConnectionPage(),
      binding: DeviceBinding(),
    ),
    GetPage(
      name: Routes.devicePage,
      page: () => const DevicePage(),
    ),
    GetPage(
      name: Routes.deviceSlavePage,
      page: () => const DeviceSlavePage(),
    ),
  ];
}

abstract class Routes {
  static const splashPage = '/';
  static const mainPage = '/main';
  static const trainingListPage = '/training_list';
  static const trainingSeriesListPage = '/training_series_list';
  static const trainingEditPage = '/training_edit';
  static const trainingSeriesEditPage = '/training_series_edit';
  static const trainingSeriesScreenPage = '/training_series_screen';
  static const deviceConnectPage = '/device_connect_page';
  static const devicePage = '/device_page';
  static const deviceSlavePage = '/device_slave_page';
}
