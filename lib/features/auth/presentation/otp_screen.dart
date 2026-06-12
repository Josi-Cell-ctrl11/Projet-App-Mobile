// Écran de saisie du code OTP — vérification téléphone
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/phone_formatter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../domain/auth_provider.dart';

/// Écran de saisie du code OTP à 6 chiffres
class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // 6 contrôleurs pour les 6 chiffres OTP
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Timer de 5 minutes (300 secondes)
  late int _secondesRestantes;
  Timer? _timer;
  bool _otpExpire = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _secondesRestantes = AppConstants.kOtpDureeMinutes * 60;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondesRestantes <= 0) {
        timer.cancel();
        setState(() => _otpExpire = true);
      } else {
        setState(() => _secondesRestantes--);
      }
    });
  }

  String get _timerDisplay {
    final minutes = _secondesRestantes ~/ 60;
    final seconds = _secondesRestantes % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _otpValue =>
      _controllers.map((c) => c.text).join();

  Future<void> _verifier() async {
    if (_otpValue.length < 6) return;
    setState(() => _errorMessage = null);

    await ref.read(authProvider.notifier).verifyOtp(widget.phone, _otpValue);

    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go('/home');
    } else {
      setState(() {
        _errorMessage = AppStrings.codeIncorrect;
        // Vider les champs OTP
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      });
    }
  }

  Future<void> _renvoyerCode() async {
    _timer?.cancel();
    setState(() {
      _otpExpire = false;
      _secondesRestantes = AppConstants.kOtpDureeMinutes * 60;
      _errorMessage = null;
      for (final c in _controllers) {
        c.clear();
      }
    });
    await ref.read(authProvider.notifier).sendOtp(widget.phone);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: const Text('Vérification'),
        backgroundColor: AppColors.kPrimaryOrange,
        foregroundColor: AppColors.kWhite,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Code de vérification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Un code à 6 chiffres a été envoyé au\n${formatPhoneDisplay(widget.phone)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.kTextSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // 6 champs OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpField(index)),
              ),
              const SizedBox(height: 16),
              // Message d'erreur
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.kRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.kRed, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.kRed,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Timer ou message expiré
              Center(
                child: _otpExpire
                    ? const Text(
                        AppStrings.codeExpire,
                        style: TextStyle(
                          color: AppColors.kRed,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 16, color: AppColors.kTextSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${AppStrings.tempsRestant}$_timerDisplay',
                            style: const TextStyle(
                              color: AppColors.kTextSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 32),
              // Bouton valider
              if (!_otpExpire)
                OzelButton(
                  label: AppStrings.validerCode,
                  onPressed: (isLoading || _otpValue.length < 6)
                      ? null
                      : _verifier,
                  isLoading: isLoading,
                ),
              // Bouton renvoyer (visible après expiration)
              if (_otpExpire) ...[
                OzelButton(
                  label: AppStrings.renvoyerCode,
                  onPressed: isLoading ? null : _renvoyerCode,
                  isLoading: isLoading,
                  variant: OzelButtonVariant.secondary,
                  icon: Icons.refresh,
                ),
              ],
              if (!_otpExpire) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: isLoading ? null : _renvoyerCode,
                    child: const Text(
                      'Renvoyer le code',
                      style: TextStyle(color: AppColors.kPrimaryOrange),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.kTextPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.kWhite,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.kGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.kPrimaryOrange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.kRed),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          // Auto-valider quand les 6 chiffres sont saisis
          if (_otpValue.length == 6) {
            _verifier();
          }
          setState(() {});
        },
      ),
    );
  }
}
