import 'dart:math';

import 'package:app/domain/managers/device_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:seon_sdk_flutter_plugin/seon_sdk_flutter_plugin.dart';

import '../utils/report_exception.dart';

class SeonManager implements DeviceFingerprintManager {
  final SeonSdkFlutterPlugin _plugin = SeonSdkFlutterPlugin();
  @override
  Future<String?> get({required String sessionId}) {
    final String id = sessionId.isEmpty ? createRandomSessionId() : sessionId;

    return _plugin.getFingerprint(id).then((String? fingerprint) {
      sentryLog('fingerprint generated');
      return fingerprint;
    }).catchError((Object error) {
      sentryLog('fingerprint error');
      Sentry.captureException(error);
      return null;
    });
  }

  String createRandomSessionId() {
    final Random r = Random();
    const String _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List<String>.generate(
      32,
      (int index) => _chars[r.nextInt(_chars.length)],
    ).join();
  }
}
