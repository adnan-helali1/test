import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/network/app_failure.dart';

String failureMessage(Object error) {
  return switch (error) {
    NetworkFailure() || TimeoutFailure() => AppCopy.networkError,
    AiNotConfiguredFailure() => AppCopy.aiDisabled,
    AiUnavailableFailure() => AppCopy.aiUnavailable,
    AppFailure() => AppCopy.loadError,
    _ => AppCopy.loadError,
  };
}
