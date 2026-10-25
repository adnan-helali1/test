import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/theme/app_colors.dart';
import 'package:e_smart/core/theme/app_radius.dart';
import 'package:e_smart/core/theme/app_shadows.dart';
import 'package:e_smart/core/theme/app_spacing.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/app_buttons.dart';

class ToastRequest {
  const ToastRequest({required this.id, required this.message});

  final int id;
  final String message;
}

class ToastController extends Notifier<ToastRequest?> {
  int _nextId = 0;

  @override
  ToastRequest? build() => null;

  void show(String message) {
    _nextId += 1;
    state = ToastRequest(id: _nextId, message: message);
  }
}

final toastProvider = NotifierProvider<ToastController, ToastRequest?>(
  ToastController.new,
);

class ToastHost extends ConsumerStatefulWidget {
  const ToastHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends ConsumerState<ToastHost> {
  ToastRequest? _visible;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _present(ToastRequest request) {
    if (_visible?.id == request.id) return;
    _timer?.cancel();
    setState(() => _visible = request);
    _timer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      setState(() => _visible = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(toastProvider, (previous, next) {
      if (next != null) _present(next);
    });
    final toast = _visible;
    final top = MediaQuery.paddingOf(context).top + 12;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (toast != null)
          PositionedDirectional(
            top: top,
            start: AppSpacing.md,
            end: AppSpacing.md,
            child: Material(
              color: AppColors.surface,
              elevation: 0,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: AppColors.toastBorder),
                  boxShadow: const [AppShadows.toast],
                ),
                child: Text(toast.message, style: AppTextStyles.body),
              ),
            ),
          ),
      ],
    );
  }
}

Future<bool> showConfirmToast(BuildContext context, String message) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppCopy.close,
    barrierColor: const Color(0x33000000),
    pageBuilder: (context, animation, secondary) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: AppColors.toastBorder),
                  boxShadow: const [AppShadows.toast],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(message, style: AppTextStyles.body),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppGoldButton(
                            label: AppCopy.confirm,
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppPrimaryButton(
                            label: AppCopy.cancel,
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  ).then((value) => value ?? false);
}
