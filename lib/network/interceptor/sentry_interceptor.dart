// ignore_for_file: depend_on_referenced_packages

import 'package:dio/dio.dart';
import 'package:sentry/sentry.dart';

class SentryInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        type: 'http',
        category: 'http',
        data: <String, dynamic>{
          'url': options.uri.toString(),
          'method': options.method,
          'queryParams': options.queryParameters,
          'data': options.data,
        },
      ),
    );
    super.onRequest(options, handler);
  }

  @override
  // ignore: always_specify_types, strict_raw_type
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        type: 'http',
        category: 'http',
        data: <String, dynamic>{
          'url': response.requestOptions.uri.toString(),
          'method': response.requestOptions.method,
          'status_code': response.statusCode,
        },
      ),
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        type: 'http',
        category: 'http',
        data: <String, dynamic>{
          'url': err.requestOptions.uri.toString(),
          'method': err.requestOptions.method,
          'status_code': err.response?.statusCode ?? 'NA',
        },
        message: DioErrorHandler.dioErrorToString(err),
      ),
    );
    super.onError(err, handler);
  }
}

mixin DioErrorHandler {
  static String dioErrorToString(DioException dioError) {
    String errorText = '';
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        errorText =
            'Connection Timeout. Check your Internet connection or contact Server adiministrator';
        break;
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        errorText =
            'Connection lost, please check your internet connection and try again.';
        break;
      case DioExceptionType.badResponse:
        errorText = _errorBaseOnHttpStatusCode(dioError);
        break;
      case DioExceptionType.unknown:
        errorText =
            'Connection lost, please check your internet connection and try again.';
        break;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        errorText =
            'Connection lost, please check your internet connection and try again.';
        break;
    }
    return errorText;
  }

  static String _errorBaseOnHttpStatusCode(DioException dioError) {
    String errorText;
    if (dioError.response != null) {
      if (dioError.response?.statusCode == 401) {
        errorText =
            'Something went wrong, please close the app and login again.';
      } else if (dioError.response?.statusCode == 404) {
        errorText =
            'Connection lost, please check your internet connection and try again.';
      } else if (dioError.response?.statusCode == 500) {
        errorText =
            "We couldn't connect to the product server. Please contact Server adiminstrator";
      } else {
        errorText =
            'Something went wrong, please close the app and login again. If the issue persists contact Server adiminstrator';
      }
    } else {
      errorText =
          'Something went wrong, please close the app and login again. If the issue persists contact Server adiminstrator';
    }

    return errorText;
  }
}
