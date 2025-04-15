import 'package:cognitive_training/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:soundpool/soundpool.dart';

import '../app_pages.dart';
import 'generated/data_controller.g.dart';
import 'options/server_options.dart';

class DataController extends DataControllerGenerated {
  //NsgPushNotificationService? nsgFirebase;

  DataController() : super() {
    requestOnInit = false;
    autoRepeate = true;
    autoRepeateCount = 1000;
  }
  Soundpool? pool;
  SoundpoolOptions soundpoolOptions = const SoundpoolOptions(maxStreams: 3, streamType: StreamType.alarm);
  Map<String, int> sounds = {};
  Map<String, String> soundsInit = {
    'count3': 'ru_3.wav',
    'count2': 'ru_2.wav',
    'count1': 'ru_1.wav',
    'count4': 'ru_4.wav',
    'count5': 'ru_5.wav',
    'count6': 'ru_6.wav',
    'count7': 'ru_7.wav',
    'count8': 'ru_8.wav',
    'count9': 'ru_9.wav',
    'count10': 'ru_10.wav',
    'start': 'ru_start.wav',
    'beep': 'beep.wav',
    'beeplong': 'beeplong.wav',
    'metronome': 'metronome.mp3'
  };

  @override
  Future onInit() async {
    provider ??=
        NsgDataProvider(applicationName: 'cognitive_trainings', firebaseToken: '', applicationVersion: '', availableServers: NsgServerOptions.availableServers);
    provider!.useNsgAuthorization = false;
    await super.onInit();
  }

  @override
  Future loadProviderData() async {
    await super.loadProviderData();
    status = GetStatus.success(NsgBaseController.emptyData);
    await _loadSounds();
    _gotoMainPage();
  }

  Future _loadSounds() async {
    if (Helper.isMobile) {
      pool = Soundpool.fromOptions(options: soundpoolOptions);
      int soundId = 0;
      soundsInit.forEach((key, fileName) async {
        var asset = await rootBundle.load("lib/assets/audios/$fileName");
        soundId = await pool!.load(asset);
        sounds[key] = soundId;
      });
    }
  }

  playSound(String soundName) {
    if (pool != null) {
      pool!.play(sounds[soundName]!);
    }
    debugPrint('${DateTime.now()} : SOUND $soundName');
  }

  bool _animationFinished = false;
  void splashAnimationFinished() {
    _animationFinished = true;
    _gotoMainPage();
  }

  bool gotoDone = false;
  void _gotoMainPage() {
    if (_animationFinished && status.isSuccess && !gotoDone) {
      gotoDone = true;
      NsgNavigator.instance.offAndToPage(Routes.trainingListPage);
    }
  }
}
