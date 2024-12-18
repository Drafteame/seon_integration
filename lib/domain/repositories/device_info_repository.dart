abstract class DeviceInfoRepository {
  Future<DeviceInfo> getDeviceInfo();
  Future<String?> getDeviceId();
  Future<String?> getDeviceFingerprint();
}

class DeviceInfo {
  const DeviceInfo({
    required this.id,
    required this.os,
    required this.osVersion,
    required this.appVersion,
    this.isPhysicalDevice,
  });

  final String id;
  final String os;
  final String osVersion;
  final String appVersion;
  final bool? isPhysicalDevice;
}
