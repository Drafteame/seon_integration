import 'package:app/network/interceptor/antifraud_interceptor_manager.dart';
import 'package:app/network/managers/http_dio_manager.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/interceptor/sentry_interceptor.dart';

final GetIt injector = GetIt.instance;

void registerDependencies() {
  _registerHttpManagers();
}

void _registerHttpManagers() {
  injector.registerLazySingleton<HttpDioManager>(
    () => HttpDioManager(
      interceptors: <InterceptorsWrapper>[
        SentryInterceptor(),
        AntifraudInterceptorManager(
          deviceInfoRepository: injector.get(),
          remoteConfigManager: injector.get(),
          featureFlagsRepository: injector.get(),
        ),
      ],
    ),
  );
}
