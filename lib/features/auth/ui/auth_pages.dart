import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/network/failure_message.dart';
import 'package:e_smart/core/storage/locale_preference.dart';
import 'package:e_smart/core/theme/app_text_styles.dart';
import 'package:e_smart/core/widgets/custom_toast.dart';
import 'package:e_smart/features/auth/data/auth_repository.dart';
import 'package:e_smart/features/auth/ui/auth_colors.dart';
import 'package:e_smart/features/auth/ui/auth_spacing.dart';
import 'package:e_smart/features/auth/ui/auth_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.from});

  final String? from;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _obscure = true;
  var _remember = false;
  var _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).login(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      context.go(widget.from ?? '/');
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AuthSpacing.xxl),
          const AppLogo(),
          const SizedBox(height: AuthSpacing.lg),
          const Text(
            'تسجيل الدخول',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AuthColors.authTitle,
            ),
          ),
          const SizedBox(height: AuthSpacing.xs),
          const Text(
            'مرحباً بعودتك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AuthColors.authSubtitle,
            ),
          ),
          const SizedBox(height: AuthSpacing.xl),
          AppBeigeTextField(
            label: 'البريد الإلكتروني',
            hint: 'أدخل بريدك الإلكتروني',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: AuthSpacing.md),
          AppBeigeTextField(
            label: 'كلمة المرور',
            hint: 'أدخل كلمة المرور',
            controller: _password,
            obscureText: _obscure,
            suffix: AuthPasswordEye(
              visible: !_obscure,
              onToggle: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: AuthSpacing.sm),
          AuthRememberRow(
            remember: _remember,
            onRememberChanged: (v) => setState(() => _remember = v),
            onForgot: () => context.push('/forgot-password'),
          ),
          const SizedBox(height: AuthSpacing.lg),
          AppMaroonButton(
            label: 'تسجيل الدخول',
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: AuthSpacing.lg),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'ليس لديك حساب؟ ',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    color: AuthColors.authMuted,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/register'),
                  child: const Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AuthColors.authLink,
                      decoration: TextDecoration.underline,
                      decorationColor: AuthColors.authLink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.xl),
        ],
      ),
    );
  }
}

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _obscure = true;
  var _obscureConfirm = true;
  var _remember = false;
  var _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (_password.text != _confirm.text) {
      ref.read(toastProvider.notifier).show('كلمتا المرور غير متطابقتين');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).register(
        email: _email.text.trim(),
        password: _password.text,
        fullName: _name.text.trim(),
        locale: ref.read(localeProvider).languageCode,
        phone: _phone.text.trim(),
      );
      if (!mounted) return;
      context.go('/');
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AuthSpacing.xxl),
          const AppLogo(),
          const SizedBox(height: AuthSpacing.lg),
          const Text(
            'تسجيل الدخول',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AuthColors.authTitle,
            ),
          ),
          const SizedBox(height: AuthSpacing.xs),
          const Text(
            'مرحباً بعودتك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AuthColors.authSubtitle,
            ),
          ),
          const SizedBox(height: AuthSpacing.xl),
          AppBeigeTextField(
            label: 'الاسم الكامل',
            hint: 'ادخل اسمك الكامل',
            controller: _name,
          ),
          const SizedBox(height: AuthSpacing.md),
          AppBeigeTextField(
            label: 'البريد الإلكتروني',
            hint: 'أدخل بريدك الإلكتروني',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: AuthSpacing.md),
          AppBeigeTextField(
            label: 'رقم الهاتف',
            hint: 'ادخل رقم هاتفك',
            controller: _phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: AuthSpacing.md),
          AppBeigeTextField(
            label: 'كلمة المرور',
            hint: 'أدخل كلمة المرور',
            controller: _password,
            obscureText: _obscure,
            suffix: AuthPasswordEye(
              visible: !_obscure,
              onToggle: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: AuthSpacing.md),
          AppBeigeTextField(
            label: 'تأكيد كلمة المرور',
            hint: 'اعد كلمة المرور',
            controller: _confirm,
            obscureText: _obscureConfirm,
            suffix: AuthPasswordEye(
              visible: !_obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          const SizedBox(height: AuthSpacing.sm),
          AuthRememberRow(
            remember: _remember,
            onRememberChanged: (v) => setState(() => _remember = v),
            onForgot: () => context.push('/forgot-password'),
          ),
          const SizedBox(height: AuthSpacing.lg),
          AppMaroonButton(
            label: 'تسجيل الدخول',
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: AuthSpacing.lg),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'لديك حساب؟ ',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    color: AuthColors.authMuted,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text(
                    'سجل دخولك',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AuthColors.authLink,
                      decoration: TextDecoration.underline,
                      decorationColor: AuthColors.authLink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.xl),
        ],
      ),
    );
  }
}

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _email = TextEditingController();
  var _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .forgotPassword(email: _email.text.trim());
      if (!mounted) return;
      context.push('/reset-password');
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AuthSpacing.xxl),
          const AppLogo(),
          const SizedBox(height: AuthSpacing.lg),
          const Text(
            'نسيت كلمة المرور؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AuthColors.authTitle,
            ),
          ),
          const SizedBox(height: AuthSpacing.sm),
          const Text(
            'أدخل بريدك الإلكتروني لإرسال رابط إعادة تعيين كلمة المرور.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AuthColors.authSubtitle,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AuthSpacing.xl),
          AppBeigeTextField(
            label: 'البريد الإلكتروني',
            hint: 'أدخل بريدك الإلكتروني',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: AuthSpacing.lg),
          AppMaroonButton(
            label: 'إرسال رابط إعادة التعيين',
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: AuthSpacing.lg),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'تذكرت كلمة المرور؟ ',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    color: AuthColors.authMuted,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AuthColors.authLink,
                      decoration: TextDecoration.underline,
                      decorationColor: AuthColors.authLink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.xl),
        ],
      ),
    );
  }
}

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, this.token});

  final String? token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _obscure = true;
  var _obscureConfirm = true;
  var _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _hasLen => _password.text.length >= 8;

  bool get _hasUpperAndDigit {
    final t = _password.text;
    return RegExp(r'[A-Z]').hasMatch(t) && RegExp(r'[0-9]').hasMatch(t);
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_hasLen || !_hasUpperAndDigit) {
      ref.read(toastProvider.notifier).show(
            'كلمة المرور لا تستوفي الشروط',
          );
      return;
    }
    if (_password.text != _confirm.text) {
      ref.read(toastProvider.notifier).show('كلمتا المرور غير متطابقتين');
      return;
    }
    final token = widget.token?.trim() ?? '';
    if (token.isEmpty) {
      // Deep-link token not present yet — keep UI and navigate after toast.
      ref.read(toastProvider.notifier).show(
            'افتح رابط إعادة التعيين من بريدك لإكمال العملية',
          );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
        token: token,
        password: _password.text,
      );
      if (!mounted) return;
      context.go('/login');
    } catch (error) {
      ref.read(toastProvider.notifier).show(failureMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AuthSpacing.xxl),
          const AppLogo(),
          const SizedBox(height: AuthSpacing.lg),
          const Text(
            'إعادة تعيين كلمة المرور',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AuthColors.authTitle,
            ),
          ),
          const SizedBox(height: AuthSpacing.sm),
          const Text(
            'أدخل كلمة المرور الجديدة الخاصة بحسابك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AuthColors.authSubtitle,
            ),
          ),
          const SizedBox(height: AuthSpacing.xl),
          AppBeigeTextField(
            label: 'كلمة المرور الجديدة',
            hint: 'أدخل كلمة المرور الجديدة',
            controller: _password,
            obscureText: _obscure,
            onChanged: (_) => setState(() {}),
            suffix: AuthPasswordEye(
              visible: !_obscure,
              onToggle: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: AuthSpacing.md),
          AppBeigeTextField(
            label: 'تأكيد كلمة المرور الجديدة',
            hint: 'أعد إدخال كلمة المرور الجديدة',
            controller: _confirm,
            obscureText: _obscureConfirm,
            suffix: AuthPasswordEye(
              visible: !_obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          const SizedBox(height: AuthSpacing.md),
          _RuleRow(met: _hasLen, label: '8 أحرف أو أكثر'),
          const SizedBox(height: AuthSpacing.xs),
          _RuleRow(
            met: _hasUpperAndDigit,
            label: 'تتضمن حرفاً كبيراً ورقماً على الأقل',
          ),
          const SizedBox(height: AuthSpacing.lg),
          AppMaroonButton(
            label: 'حفظ وتعيين كلمة المرور',
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: AuthSpacing.lg),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'تذكرت كلمة المرور؟ ',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    color: AuthColors.authMuted,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AuthColors.authLink,
                      decoration: TextDecoration.underline,
                      decorationColor: AuthColors.authLink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.xl),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = met ? AuthColors.authCheckMet : AuthColors.authCheckIdle;
    return Row(
      children: [
        Icon(Icons.check_circle, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
