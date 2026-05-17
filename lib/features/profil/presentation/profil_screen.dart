// Écran du profil livreur OZELSERVICES
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/models/document.dart';
import '../../../shared/models/livreur.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_card.dart';
import '../../../shared/widgets/ozel_loading.dart';
import '../../auth/domain/auth_provider.dart';
import '../domain/profil_provider.dart';

/// Écran du profil livreur avec documents et déconnexion
class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilAsync = ref.watch(profilProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: const Text(AppStrings.profil),
        backgroundColor: AppColors.kPrimaryOrange,
        foregroundColor: AppColors.kWhite,
      ),
      body: profilAsync.when(
        loading: () => const Center(child: OzelSpinner(size: 40)),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.kRed, size: 48),
              const SizedBox(height: 12),
              const Text(AppStrings.erreurReseau),
            ],
          ),
        ),
        data: (livreur) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Bandeau avertissement note insuffisante
              if (livreur.note < AppConstants.kNoteMinimale)
                _AvertissementNote(),
              const SizedBox(height: 8),
              // Carte profil principale
              _CarteProfilPrincipale(livreur: livreur),
              const SizedBox(height: 16),
              // Sélecteur de véhicule
              _SelecteurVehicule(livreur: livreur, ref: ref),
              const SizedBox(height: 16),
              // Documents
              _SectionDocuments(documents: livreur.documents),
              const SizedBox(height: 16),
              // Statistiques
              _SectionStats(livreur: livreur),
              const SizedBox(height: 24),
              // Bouton déconnexion
              OzelButton(
                label: AppStrings.deconnexion,
                onPressed: () => _confirmerDeconnexion(context, ref),
                variant: OzelButtonVariant.danger,
                icon: Icons.logout,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmerDeconnexion(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kRed),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}

class _AvertissementNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.kRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kRed.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber, color: AppColors.kRed, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.avertissementNote,
              style: TextStyle(color: AppColors.kRed, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteProfilPrincipale extends StatelessWidget {
  final Livreur livreur;
  const _CarteProfilPrincipale({required this.livreur});

  @override
  Widget build(BuildContext context) {
    return OzelCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.kPrimaryOrange.withValues(alpha: 0.15),
                child: livreur.photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          livreur.photoUrl!,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        livreur.prenom.isNotEmpty
                            ? livreur.prenom[0].toUpperCase()
                            : 'L',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kPrimaryOrange,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.kPrimaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: AppColors.kWhite, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nom
          Text(
            livreur.nomComplet,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            livreur.telephone,
            style: const TextStyle(
              color: AppColors.kTextSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          // Note en étoiles
          _NoteEtoiles(note: livreur.note),
        ],
      ),
    );
  }
}

class _NoteEtoiles extends StatelessWidget {
  final double note;
  const _NoteEtoiles({required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(5, (i) {
          final filled = i < note.floor();
          final half = !filled && i < note;
          return Icon(
            half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
            color: AppColors.kYellow,
            size: 22,
          );
        }),
        const SizedBox(width: 6),
        Text(
          note.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Text(
          ' / 5',
          style: TextStyle(color: AppColors.kTextSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

class _SelecteurVehicule extends StatelessWidget {
  final Livreur livreur;
  final WidgetRef ref;
  const _SelecteurVehicule({required this.livreur, required this.ref});

  @override
  Widget build(BuildContext context) {
    return OzelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Type de véhicule',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: TypeVehicule.values.map((v) {
              final isSelected = livreur.typeVehicule == v;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      ref.read(profilProvider.notifier).updateVehicule(v),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.kPrimaryOrange
                          : AppColors.kGreyLight,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.kGrey.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _vehiculeIcon(v),
                          color: isSelected
                              ? AppColors.kWhite
                              : AppColors.kTextSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _vehiculeLabel(v),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.kWhite
                                : AppColors.kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _vehiculeIcon(TypeVehicule v) {
    switch (v) {
      case TypeVehicule.moto:
        return Icons.two_wheeler;
      case TypeVehicule.velo:
        return Icons.pedal_bike;
      case TypeVehicule.voiture:
        return Icons.directions_car;
    }
  }

  String _vehiculeLabel(TypeVehicule v) {
    switch (v) {
      case TypeVehicule.moto:
        return AppStrings.moto;
      case TypeVehicule.velo:
        return AppStrings.velo;
      case TypeVehicule.voiture:
        return AppStrings.voiture;
    }
  }
}

class _SectionDocuments extends StatelessWidget {
  final List<Document> documents;
  const _SectionDocuments({required this.documents});

  @override
  Widget build(BuildContext context) {
    return OzelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.documents,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...documents.map((doc) => _DocumentItem(document: doc)),
        ],
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final Document document;
  const _DocumentItem({required this.document});

  @override
  Widget build(BuildContext context) {
    final (label, icone, couleur) = _getInfo();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(_typeIcon(), color: AppColors.kTextSecondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _typeLabel(),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icone, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: couleur,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, String, Color) _getInfo() {
    switch (document.statut) {
      case StatutDocument.valide:
        return (AppStrings.valide, '✅', AppColors.kGreen);
      case StatutDocument.enAttente:
        return (AppStrings.enAttenteValidation, '⚠️', AppColors.kYellow);
      case StatutDocument.manquant:
        return (AppStrings.manquant, '❌', AppColors.kRed);
    }
  }

  IconData _typeIcon() {
    switch (document.type) {
      case TypeDocument.cni:
        return Icons.badge;
      case TypeDocument.permis:
        return Icons.drive_eta;
      case TypeDocument.assurance:
        return Icons.security;
    }
  }

  String _typeLabel() {
    switch (document.type) {
      case TypeDocument.cni:
        return AppStrings.cni;
      case TypeDocument.permis:
        return AppStrings.permis;
      case TypeDocument.assurance:
        return AppStrings.assurance;
    }
  }
}

class _SectionStats extends StatelessWidget {
  final Livreur livreur;
  const _SectionStats({required this.livreur});

  @override
  Widget build(BuildContext context) {
    return OzelCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            valeur: '${livreur.totalLivraisons}',
            label: AppStrings.totalLivraisons,
            icone: Icons.delivery_dining,
          ),
          Container(width: 1, height: 40, color: AppColors.kGreyLight),
          _StatItem(
            valeur: livreur.note.toStringAsFixed(1),
            label: 'Note moyenne',
            icone: Icons.star,
            couleur: AppColors.kYellow,
          ),
          Container(width: 1, height: 40, color: AppColors.kGreyLight),
          _StatItem(
            valeur: _vehiculeLabel(livreur.typeVehicule),
            label: 'Véhicule',
            icone: Icons.two_wheeler,
          ),
        ],
      ),
    );
  }

  String _vehiculeLabel(TypeVehicule v) {
    switch (v) {
      case TypeVehicule.moto:
        return 'Moto';
      case TypeVehicule.velo:
        return 'Vélo';
      case TypeVehicule.voiture:
        return 'Voiture';
    }
  }
}

class _StatItem extends StatelessWidget {
  final String valeur;
  final String label;
  final IconData icone;
  final Color couleur;

  const _StatItem({
    required this.valeur,
    required this.label,
    required this.icone,
    this.couleur = AppColors.kPrimaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, color: couleur, size: 22),
        const SizedBox(height: 4),
        Text(
          valeur,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.kTextSecondary,
          ),
        ),
      ],
    );
  }
}
