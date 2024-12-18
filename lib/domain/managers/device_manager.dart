abstract class DeviceInfoManager {
  static const String web = 'Web';
  static const String ios = 'iOS';
  static const String iosWeb = '$web - iOS Browser';
  static const String android = 'Android';
  static const String androidWeb = '$web - Android Browser';

  Future<String> getSystemVersion();
  Future<String> getPlatform();
  Future<bool?> isPhysicalDevice();
}

abstract class DeviceIdentifierManager {
  Future<String> getDeviceId();
}

abstract class DeviceFingerprintManager {
  Future<String?> get({required String sessionId});
}
