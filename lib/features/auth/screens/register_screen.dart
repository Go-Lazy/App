import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_text_field.dart';

/// Registration flow: enter phone -> send OTP -> enter the OTP, a password
/// and (optionally) a name, in a single screen with progressive disclosure.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _otpSent = false;
  bool _isSendingOtp = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _errorMessage = 'Enter a valid phone number.');
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
    });

    try {
      final debugOtp = await ref.read(authControllerProvider.notifier).sendOtp(phone);
      setState(() {
        _otpSent = true;
        // The backend currently echoes the OTP for development since no SMS
        // provider is wired up yet; pre-fill it purely as a dev convenience.
        if (debugOtp != null) _otpController.text = debugOtp;
      });
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (otp.length != 6 || password.length < 6) {
      setState(() => _errorMessage = 'Enter the 6-digit OTP and a password of at least 6 characters.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).register(
            phone: phone,
            otp: otp,
            password: password,
            name: name.isEmpty ? null : name,
          );
      if (mounted) context.pop();
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join GoLazy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                "We'll verify your phone number with a one-time code first.",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              AuthTextField(
                label: 'Phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                hintText: '98765 43210',
                enabled: !_otpSent,
              ),
              const SizedBox(height: 12),
              if (!_otpSent)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isSendingOtp ? null : _sendOtp,
                    child: _isSendingOtp
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send OTP'),
                  ),
                ),
              if (_otpSent) ...[
                TextButton(
                  onPressed: _isSendingOtp ? null : _sendOtp,
                  child: const Text('Resend OTP'),
                ),
                const SizedBox(height: 8),
                AuthTextField(
                  label: 'OTP',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  hintText: '6-digit code',
                  maxLength: 6,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Full name (optional)',
                  controller: _nameController,
                  hintText: 'Your name',
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  hintText: 'At least 6 characters',
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                AuthErrorBanner(message: _errorMessage!),
              ],
              if (_otpSent) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Create account'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.pushReplacement(AppRoutes.login),
                  child: const Text('Already have an account? Log in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
