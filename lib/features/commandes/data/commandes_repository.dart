// Repository des commandes — implémentation mock pour MVP
import 'dart:math';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/commande.dart';
import 'mock_commandes_data.dart';

/// Interface du repository des commandes
abstract class ICommandesRepository {
  Future<List<Commande>> getCommandesDisponibles();
  Future<void> accepterCommande(String commandeId);
  Future<void> refuserCommande(String commandeId);
  Future<void> updateStatutCommande(String commandeId, StatutCommande statut);
  Future<bool> confirmerLivraisonOtp(String commandeId, String otp);
}

/// Implémentation mock du repository des commandes
class MockCommandesRepository implements ICommandesRepository {
  final Random _random = Random();

  // État local des commandes (simulé en mémoire)
  final List<Commande> _commandes = List.from(mockCommandes);

  /// Simule un délai réseau réaliste
  Future<void> _simulerDelai() async {
    final delai = AppConstants.kDelaiMockReseau +
        _random.nextInt(
            AppConstants.kDelaiMockReseauMax - AppConstants.kDelaiMockReseau);
    await Future.delayed(Duration(milliseconds: delai));
  }

  @override
  Future<List<Commande>> getCommandesDisponibles() async {
    await _simulerDelai();
    // Retourne uniquement les commandes disponibles
    return _commandes
        .where((c) => c.statut == StatutCommande.disponible)
        .toList();
  }

  @override
  Future<void> accepterCommande(String commandeId) async {
    await _simulerDelai();
    final index = _commandes.indexWhere((c) => c.id == commandeId);
    if (index != -1) {
      _commandes[index] =
          _commandes[index].copyWith(statut: StatutCommande.acceptee);
    }
  }

  @override
  Future<void> refuserCommande(String commandeId) async {
    await _simulerDelai();
    // En production : notifier le backend du refus
    // Pour le mock, on retire simplement la commande de la liste disponible
    final index = _commandes.indexWhere((c) => c.id == commandeId);
    if (index != -1) {
      _commandes[index] =
          _commandes[index].copyWith(statut: StatutCommande.annulee);
    }
  }

  @override
  Future<void> updateStatutCommande(
      String commandeId, StatutCommande statut) async {
    await _simulerDelai();
    final index = _commandes.indexWhere((c) => c.id == commandeId);
    if (index != -1) {
      _commandes[index] = _commandes[index].copyWith(statut: statut);
    }
  }

  @override
  Future<bool> confirmerLivraisonOtp(String commandeId, String otp) async {
    await _simulerDelai();
    final commande = _commandes.firstWhere(
      (c) => c.id == commandeId,
      orElse: () => throw Exception('Commande introuvable'),
    );
    // Vérification de l'OTP
    if (commande.otpCode == otp) {
      final index = _commandes.indexWhere((c) => c.id == commandeId);
      _commandes[index] =
          _commandes[index].copyWith(statut: StatutCommande.livree);
      return true;
    }
    return false;
  }

  /// Récupère une commande par son ID
  Commande? getCommandeById(String id) {
    try {
      return _commandes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
