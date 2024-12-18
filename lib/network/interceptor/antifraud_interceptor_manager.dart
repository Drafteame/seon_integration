import 'package:app/domain/repositories/remote_config_repository.dart';
import 'package:dio/dio.dart';

import '../../domain/repositories/device_info_repository.dart';
import '../../domain/repositories/feature_flag_repository.dart';

class AntifraudInterceptorManager extends InterceptorsWrapper {
  AntifraudInterceptorManager({
    required DeviceInfoRepository deviceInfoRepository,
    required RemoteConfigRepository remoteConfigManager,
    required FeatureFlagsRepository featureFlagsRepository,
  })  : _deviceInfo = deviceInfoRepository,
        _remoteConfigManager = remoteConfigManager,
        _flagsRepository = featureFlagsRepository;

  final DeviceInfoRepository _deviceInfo;
  final RemoteConfigRepository _remoteConfigManager;
  final FeatureFlagsRepository _flagsRepository;

  String? _sessionId;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_flagsRepository.isSeonEnabled && await hasToAddInformation(options)) {
      final Map<String, dynamic> requestData =
          options.data as Map<String, dynamic>;

      final String sessionId = await getSessionId();
      final String? fingerPrint = await getFingerprint();

      if (fingerPrint == null) {
        return handler.next(options);
      }

      requestData['metadata'] = <String, dynamic>{
        ...requestData['metadata'] as Map<String, dynamic>? ??
            <String, dynamic>{},
        'deviceSession': 'seon:$sessionId',
        'fingerprint': 'seon:$fingerPrint',
      };

      options = options.copyWith(data: requestData);
    }
    return handler.next(options);
  }

  Future<String> getSessionId() async {
    _sessionId ??= await _deviceInfo.getDeviceId();
    return _sessionId!;
  }

  Future<String?> getFingerprint() => _deviceInfo.getDeviceFingerprint();

  Future<bool> hasToAddInformation(RequestOptions requestOptions) async {
    final List<String> endpoints = _remoteConfigManager.antifraudEndpoints;
    return requestOptions.data is Map<String, dynamic> &&
        (endpoints.any((String path) {
          return path.isNotEmpty && requestOptions.path.contains(path);
        }));
  }
}

