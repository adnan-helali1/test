import 'package:flutter/material.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/features/auth/ui/auth_colors.dart';
import 'package:e_smart/features/auth/ui/auth_spacing.dart';

/// Ornate keyhole logo asset. Do not recolor or distort.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = AuthSpacing.logoSize});

  static const assetPath = 'assets/images/dar_nassri_logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        assetPath,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class AppBeigeTextField extends StatelessWidget {
  const AppBeigeTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textDirection,
    this.suffix,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AuthColors.authLabel,
          ),
        ),
        const SizedBox(height: AuthSpacing.xs),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textDirection: textDirection,
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2B1A1B),
          ),
          cursorColor: AuthColors.authButton,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AuthColors.authHint,
            ),
            filled: true,
            fillColor: AuthColors.authInputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuthSpacing.fieldRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuthSpacing.fieldRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuthSpacing.fieldRadius),
              borderSide: const BorderSide(
                color: Color(0x33490D0E),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppMaroonButton extends StatelessWidget {
  const AppMaroonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AuthSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.authButton,
          foregroundColor: AuthColors.authTitle,
          disabledBackgroundColor: AuthColors.authButton.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthSpacing.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AuthColors.authTitle,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AuthSpacing.pagePadding,
          ),
          child: child,
        ),
      ),
    );
  }
}

class AuthPasswordEye extends StatelessWidget {
  const AuthPasswordEye({
    super.key,
    required this.visible,
    required this.onToggle,
  });

  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AuthColors.authHint,
        size: 22,
      ),
    );
  }
}

class AuthRememberRow extends StatelessWidget {
  const AuthRememberRow({
    super.key,
    required this.remember,
    required this.onRememberChanged,
    required this.onForgot,
  });

  final bool remember;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onForgot;

  @override
  Widget build(BuildContext context) {
    // RTL: first child sits on the right — match screenshot (تذكرني | نسيت).
    return Row(
      children: [
        GestureDetector(
          onTap: () => onRememberChanged(!remember),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تذكرني',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AuthColors.authLink,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: remember,
                  onChanged: (v) => onRememberChanged(v ?? false),
                  side: const BorderSide(color: AuthColors.authLink, width: 1.4),
                  activeColor: AuthColors.authButton,
                  checkColor: AuthColors.authTitle,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onForgot,
          style: TextButton.styleFrom(
            foregroundColor: AuthColors.authLink,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          child: const Text('نسيت كلمة المرور؟'),
        ),
      ],
    );
  }
}
