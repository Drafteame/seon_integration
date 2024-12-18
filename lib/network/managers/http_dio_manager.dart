import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../interceptor/dio_firebase_performance.dart';

class HttpDioManager {
  HttpDioManager({
    required List<InterceptorsWrapper> interceptors,
  }) {
    _dio = Dio(
      BaseOptions(
        contentType: 'application/json; charset=UTF-8',
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          ApiHeaders.language: 'es',
          ApiHeaders.drafteaVersion: ApiHeaders.baseApiVersion,
        },
      ),
    );

    _modifyUserAgent();

    _dio.interceptors.add(DioFirebasePerformanceInterceptor());
    _dio.interceptors.addAll(interceptors);

    if (!kReleaseMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
        ),
      );
    }
  }

  late Dio _dio;

  static const String bearerPrefix = 'Bearer';
  static const String basicPrefix = 'Basic';
  static const String userAgentHeader = 'User-Agent';

  void _modifyUserAgent() {
    final HttpClientAdapter adapter = _dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final HttpClient client = HttpClient()
          ..idleTimeout = const Duration(seconds: 3);

        _dio.options = _dio.options.copyWith(
          headers: <String, dynamic>{
            ..._dio.options.headers,
            userAgentHeader: '${client.userAgent ?? ''} DrafteaApp/',
          },
        );

        return client;
      };
    }
  }
}

mixin ApiHeaders {
  static const String language = 'X-Language';
  static const String drafteaVersion = 'Draftea-Version';
  static const String baseApiVersion = '2023-01-27';
}
