// Service timer — compte à rebours de 30 secondes pour acceptation commande
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

/// État du timer d'acceptation
class TimerState {
  final int secondesRestantes;
  final bool estExpire;

  const TimerState({
    required this.secondesRestantes,
    required this.estExpire,
  });

  const TimerState.initial()
      : secondesRestantes = AppConstants.kTimerAcceptationSecondes,
        estExpire = false;
}

/// Provider du timer par commande (family = un timer par commandeId)
final timerProvider = StateNotifierProvider.family<TimerNotifier, TimerState, String>(
  (ref, commandeId) => TimerNotifier(),
);

/// Notifier gérant le décompte de 30 secondes pour une commande
class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;

  TimerNotifier() : super(const TimerState.initial()) {
    _demarrer();
  }

  /// Démarre le compte à rebours
  void _demarrer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondesRestantes <= 1) {
        timer.cancel();
        state = const TimerState(secondesRestantes: 0, estExpire: true);
      } else {
        state = TimerState(
          secondesRestantes: state.secondesRestantes - 1,
          estExpire: false,
        );
      }
    });
  }

  /// Réinitialise le timer
  void reset() {
    _timer?.cancel();
    state = const TimerState.initial();
    _demarrer();
  }

  /// Arrête le timer (commande acceptée ou refusée)
  void arreter() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
