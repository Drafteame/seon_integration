import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> reportException(
  Object failure, {
  dynamic stackTrace,
  void Function(Scope)? withScope,
}) async {
  Sentry.captureException(
    failure,
    stackTrace: stackTrace,
    withScope: withScope,
  );
}

void sentryLog(String message, {Map<String, dynamic>? data}) {
  Sentry.addBreadcrumb(
    Breadcrumb(
      message: message,
      data: data,
    ),
  );
  if (!kReleaseMode) {
    debugPrint(
      '$message  ${data?.let((Map<String, dynamic> it) => it.toString()) ?? ''}',
    );
  }
}

extension ScopeFuncs<T extends Object> on T {
  R let<R>(R Function(T it) scopeFunc) {
    return scopeFunc(this);
  }

  T also(void Function(T self) scopeFunc) {
    scopeFunc(this);
    return this;
  }

  void run(void Function(T it) scopeFunc) {
    scopeFunc(this);
  }
}
