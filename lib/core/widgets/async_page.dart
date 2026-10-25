import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/network/failure_message.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/widgets/empty_state.dart';

class AsyncPage<T> extends StatelessWidget {
  const AsyncPage({
    super.key,
    required this.value,
    required this.onRetry,
    required this.data,
  });

  final AsyncValue<T> value;
  final Future<void> Function() onRetry;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ),
      error: (error, _) => LoadFailure(message: failureMessage(error), onRetry: onRetry),
      data: data,
    );
  }
}

class LoadFailure extends StatelessWidget {
  const LoadFailure({super.key, required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: message,
      icon: Icons.wifi_off_rounded,
      actionLabel: AppCopy.retry,
      onAction: () {
        onRetry();
      },
    );
  }
}

class PageScaffoldPadding {
  static const edge = EdgeInsets.fromLTRB(
    AppSpacing.page,
    AppSpacing.page,
    AppSpacing.page,
    AppSpacing.pageBottom,
  );
}
