import 'dart:io';

import 'package:flutter/foundation.dart';

class Helper {
  static bool get isMobile => (!kIsWeb && (Platform.isAndroid || Platform.isIOS));
}
