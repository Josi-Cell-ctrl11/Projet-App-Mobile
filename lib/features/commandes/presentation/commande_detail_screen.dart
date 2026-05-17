// Écran détail d'une commande acceptée avec progression séquentielle
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_card.dart';
import '../domain/commandes_provider.dart';

/// Écran de détail d'une commande acceptée
class CommandeDetailScreen extends ConsumerWidget {
  final String commandeId;
  const CommandeDetailScreen({super.key, required this.commandeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commande = ref.watch(activeCommandeProvider);

    if (commande == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Commande')),
        body: const Center(child: Text('Commande introuvable')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Text('Commande #${commande.id.substring(4)}'),
        backgroundColor: AppColors.kPrimaryOrange,
        foregroundColor: AppColors.kWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_outlined),
            tooltip: 'Signaler un problème',
            onPressed: () => _signalerProbleme(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progression des étapes
            _ProgressionEtapes(statut: commande.statut),
            const SizedBox(height: 16),
            // Infos client
            _InfoClient(commande: commande),
            const SizedBox(height: 12),
            // Adresses
            _InfoAdresses(commande: commande),
            const SizedBox(height: 12),
            // Description articles/colis
            _InfoArticles(commande: commande),
            const SizedBox(height: 12),
            // Code OTP de livraison
            _CodeOtp(otpCode: commande.otpCode ?? '------'),
            const SizedBox(height: 20),
            // Boutons d'action séquentiels
            _BoutonsAction(commande: commande, ref: ref, context: context),
            const SizedBox(height: 16),
            // Bouton navigation GPS
            OzelButton(
              label: 'Ouvrir la navigation GPS',
              onPressed: () =>
                  context.push('/home/commandes/${commande.id}/navigation'),
              variant: OzelButtonVariant.secondary,
              icon: Icons.navigation,
            ),
          ],
        ),
      ),
    );
  }

  void _signalerProbleme(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Décrivez le problème rencontré...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Problème signalé avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimaryOrange),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}

class _ProgressionEtapes extends StatelessWidget {
  final StatutCommande statut;
  const _ProgressionEtapes({required this.statut});

  @override
  Widget build(BuildContext context) {
    final etapes = [
      _Etape('Acceptée', StatutCommande.acceptee, Icons.check_circle),
      _Etape('Au pickup', StatutCommande.auPickup, Icons.store),
      _Etape('En route', StatutCommande.enRoute, Icons.delivery_dining),
      _Etape('Livrée', StatutCommande.livree, Icons.done_all),
    ];

    final statutIndex = etapes.indexWhere((e) => e.statut == statut);

    return OzelCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: etapes.asMap().entries.map((entry) {
          final i = entry.key;
          final etape = entry.value;
          final estActif = i <= statutIndex;
          final estCourant = i == statutIndex;

          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: estActif
                            ? AppColors.kPrimaryOrange
                            : AppColors.kGreyLight,
                        shape: BoxShape.circle,
                        border: estCourant
                            ? Border.all(
                                color: AppColors.kPrimaryOrange, width: 2)
                            : null,
                      ),
                      child: Icon(
                        etape.icone,
                        size: 16,
                        color: estActif
                            ? AppColors.kWhite
                            : AppColors.kGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      etape.label,
                      style: TextStyle(
                        fontSize: 9,
                        color: estActif
                            ? AppColors.kPrimaryOrange
                            : AppColors.kGrey,
                        fontWeight: estCourant
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                if (i < etapes.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: i < statutIndex
                          ? AppColors.kPrimaryOrange
                          : AppColors.kGreyLight,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Etape {
  final String label;
  final StatutCommande statut;
  final IconData icone;
  const _Etape(this.label, this.statut, this.icone);
}

class _InfoClient extends StatelessWidget {
  final Commande commande;
  const _InfoClient({required this.commande});

  Future<void> _appelerClient() async {
    final uri = Uri.parse('tel:${commande.clientTelephone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OzelCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.kPrimaryOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.kPrimaryOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commande.clientNom,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  // Masquer partiellement le numéro
                  _masquerTelephone(commande.clientTelephone),
                  style: const TextStyle(
                    color: AppColors.kTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Bouton appel direct
          IconButton(
            onPressed: _appelerClient,
            icon: const Icon(Icons.phone, color: AppColors.kGreen),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.kGreen.withValues(alpha: 0.1),
            ),
            tooltip: AppStrings.appelerClient,
          ),
        ],
      ),
    );
  }

  String _masquerTelephone(String tel) {
    if (tel.length < 6) return tel;
    return '${tel.substring(0, tel.length - 4)}****';
  }
}

class _InfoAdresses extends StatelessWidget {
  final Commande commande;
  const _InfoAdresses({required this.commande});

  @override
  Widget build(BuildContext context) {
    return OzelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Itinéraire',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _AdresseLine(
            icone: Icons.store,
            couleur: AppColors.kPrimaryOrange,
            label: AppStrings.pickup,
            adresse: commande.adressePickup.libelle,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Container(
              width: 2,
              height: 20,
              color: AppColors.kGreyLight,
            ),
          ),
          _AdresseLine(
            icone: Icons.location_on,
            couleur: AppColors.kRed,
            label: AppStrings.livraison,
            adresse: commande.adresseLivraison.libelle,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.route, size: 14, color: AppColors.kTextSecondary),
              const SizedBox(width: 4),
              Text(
                '${Formatters.formatDistance(commande.distanceKm)} • ${Formatters.formatDuree(commande.tempsEstimeMinutes)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.kTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdresseLine extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final String label;
  final String adresse;

  const _AdresseLine({
    required this.icone,
    required this.couleur,
    required this.label,
    required this.adresse,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: couleur, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.kTextSecondary,
                ),
              ),
              Text(
                adresse,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoArticles extends StatelessWidget {
  final Commande commande;
  const _InfoArticles({required this.commande});

  @override
  Widget build(BuildContext context) {
    final isFood = commande.type == TypeCommande.ozelFoods;
    return OzelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFood ? Icons.restaurant_menu : Icons.inventory_2,
                color: AppColors.kPrimaryOrange,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isFood ? 'Articles commandés' : 'Description du colis',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            commande.descriptionArticles,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeOtp extends StatelessWidget {
  final String otpCode;
  const _CodeOtp({required this.otpCode});

  @override
  Widget build(BuildContext context) {
    return OzelCard(
      padding: const EdgeInsets.all(16),
      border: Border.all(
        color: AppColors.kPrimaryOrange.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.kPrimaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock, color: AppColors.kPrimaryOrange),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Code OTP de livraison',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.kTextSecondary,
                ),
              ),
              Text(
                otpCode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kPrimaryOrange,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'À saisir\npar le client',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.kTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BoutonsAction extends StatelessWidget {
  final Commande commande;
  final WidgetRef ref;
  final BuildContext context;

  const _BoutonsAction({
    required this.commande,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final statut = commande.statut;

    return Column(
      children: [
        // Bouton "Je suis au pickup"
        OzelButton(
          label: AppStrings.jesuisAuPickup,
          onPressed: statut == StatutCommande.acceptee
              ? () => ref
                  .read(commandesProvider.notifier)
                  .updateStatut(commande.id, StatutCommande.auPickup)
              : null,
          icon: Icons.store,
          height: 48,
        ),
        const SizedBox(height: 10),
        // Bouton "En route"
        OzelButton(
          label: AppStrings.enRoute,
          onPressed: statut == StatutCommande.auPickup
              ? () => ref
                  .read(commandesProvider.notifier)
                  .updateStatut(commande.id, StatutCommande.enRoute)
              : null,
          icon: Icons.delivery_dining,
          height: 48,
        ),
        const SizedBox(height: 10),
        // Bouton "Livré" → ouvre confirmation OTP
        OzelButton(
          label: AppStrings.livre,
          onPressed: statut == StatutCommande.enRoute
              ? () => context
                  .push('/home/commandes/${commande.id}/confirmation')
              : null,
          icon: Icons.check_circle,
          height: 48,
        ),
      ],
    );
  }
}
