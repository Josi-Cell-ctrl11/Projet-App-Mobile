// Écran d'inscription livreur — onboarding en 3 étapes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/phone_formatter.dart';
import '../../../shared/models/livreur.dart';
import '../../../shared/widgets/ozel_button.dart';
import '../../../shared/widgets/ozel_text_field.dart';

/// Données d'inscription collectées sur les 3 étapes
class _InscriptionData {
  // Étape 1 — Identité
  String prenom = '';
  String nom = '';
  String telephone = '';

  // Étape 2 — Véhicule
  TypeVehicule typeVehicule = TypeVehicule.moto;
  String numeroCni = '';
  String numeroPermis = '';

  // Étape 3 — Photo profil (mock)
  bool photoAjoutee = false;
}

/// Écran d'inscription livreur en 3 étapes
class InscriptionScreen extends ConsumerStatefulWidget {
  const InscriptionScreen({super.key});

  @override
  ConsumerState<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends ConsumerState<InscriptionScreen> {
  int _etapeCourante = 0;
  final _data = _InscriptionData();
  bool _isLoading = false;

  final List<String> _titresEtapes = [
    'Informations personnelles',
    'Véhicule & Documents',
    'Photo de profil',
  ];

  void _etapeSuivante() {
    if (_etapeCourante < 2) {
      setState(() => _etapeCourante++);
    } else {
      _soumettre();
    }
  }

  void _etapePrecedente() {
    if (_etapeCourante > 0) {
      setState(() => _etapeCourante--);
    } else {
      context.pop();
    }
  }

  Future<void> _soumettre() async {
    setState(() => _isLoading = true);
    // Simulation d'envoi (2 secondes)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    _afficherSucces();
  }

  void _afficherSucces() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.kGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.kWhite, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Inscription envoyée !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Votre dossier est en cours de validation par l\'équipe OZELSERVICES. Vous recevrez un SMS dès que votre compte est activé.',
              style: TextStyle(color: AppColors.kTextSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OzelButton(
              label: 'Se connecter',
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryOrange,
        foregroundColor: AppColors.kWhite,
        title: const Text('Devenir livreur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _etapePrecedente,
        ),
      ),
      body: Column(
        children: [
          // Indicateur de progression
          _ProgressionEtapes(
            etapeCourante: _etapeCourante,
            titres: _titresEtapes,
          ),
          // Contenu de l'étape
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildEtape(),
              ),
            ),
          ),
          // Bouton navigation
          Padding(
            padding: const EdgeInsets.all(24),
            child: OzelButton(
              label: _etapeCourante < 2 ? 'Continuer' : 'Soumettre mon dossier',
              onPressed: _isLoading ? null : _etapeSuivante,
              isLoading: _isLoading,
              icon: _etapeCourante < 2 ? Icons.arrow_forward : Icons.send,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtape() {
    switch (_etapeCourante) {
      case 0:
        return _Etape1(key: const ValueKey(0), data: _data, onChanged: () => setState(() {}));
      case 1:
        return _Etape2(key: const ValueKey(1), data: _data, onChanged: () => setState(() {}));
      case 2:
        return _Etape3(key: const ValueKey(2), data: _data, onChanged: () => setState(() {}));
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Indicateur de progression ─────────────────────────────────────────────────

class _ProgressionEtapes extends StatelessWidget {
  final int etapeCourante;
  final List<String> titres;

  const _ProgressionEtapes({
    required this.etapeCourante,
    required this.titres,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Étape x sur 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Étape ${etapeCourante + 1} sur ${titres.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.kTextSecondary,
                ),
              ),
              Text(
                titres[etapeCourante],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kPrimaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (etapeCourante + 1) / titres.length,
              backgroundColor: AppColors.kGreyLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.kPrimaryOrange,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Étape 1 : Identité ────────────────────────────────────────────────────────

class _Etape1 extends StatefulWidget {
  final _InscriptionData data;
  final VoidCallback onChanged;

  const _Etape1({super.key, required this.data, required this.onChanged});

  @override
  State<_Etape1> createState() => _Etape1State();
}

class _Etape1State extends State<_Etape1> {
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _nomCtrl;
  late final TextEditingController _telCtrl;

  @override
  void initState() {
    super.initState();
    _prenomCtrl = TextEditingController(text: widget.data.prenom);
    _nomCtrl = TextEditingController(text: widget.data.nom);
    _telCtrl = TextEditingController(
      text: widget.data.telephone.isEmpty
          ? ''
          : formatLocalPhone(phoneLocalFromE164(widget.data.telephone)),
    );
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icone: Icons.person_rounded,
          titre: 'Qui êtes-vous ?',
          sousTitre: 'Ces informations apparaîtront sur votre profil livreur.',
        ),
        const SizedBox(height: 24),
        OzelTextField(
          label: 'Prénom',
          hint: 'Ex: Kouassi',
          controller: _prenomCtrl,
          prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.kPrimaryOrange),
          onChanged: (v) {
            widget.data.prenom = v;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        OzelTextField(
          label: 'Nom de famille',
          hint: 'Ex: Ahounou',
          controller: _nomCtrl,
          prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.kPrimaryOrange),
          onChanged: (v) {
            widget.data.nom = v;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        OzelTextField(
          label: 'Numéro de téléphone',
          hint: '0166272826',
          controller: _telCtrl,
          keyboardType: TextInputType.phone,
          prefixText: '+229 ',
          prefixIcon: const Icon(Icons.phone, color: AppColors.kPrimaryOrange),
          inputFormatters: [PhoneBeninInputFormatter()],
          onChanged: (v) {
            widget.data.telephone = phoneToE164(v);
            widget.onChanged();
          },
        ),
        const SizedBox(height: 24),
        // Info RGPD
        _InfoBox(
          icone: Icons.lock_outline,
          texte: 'Vos informations sont confidentielles et ne seront '
              'partagées qu\'avec les clients lors des livraisons.',
        ),
      ],
    );
  }
}

// ── Étape 2 : Véhicule & Documents ───────────────────────────────────────────

class _Etape2 extends StatefulWidget {
  final _InscriptionData data;
  final VoidCallback onChanged;

  const _Etape2({super.key, required this.data, required this.onChanged});

  @override
  State<_Etape2> createState() => _Etape2State();
}

class _Etape2State extends State<_Etape2> {
  late final TextEditingController _cniCtrl;
  late final TextEditingController _permisCtrl;

  @override
  void initState() {
    super.initState();
    _cniCtrl = TextEditingController(text: widget.data.numeroCni);
    _permisCtrl = TextEditingController(text: widget.data.numeroPermis);
  }

  @override
  void dispose() {
    _cniCtrl.dispose();
    _permisCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icone: Icons.two_wheeler,
          titre: 'Votre véhicule',
          sousTitre: 'Sélectionnez le type de véhicule que vous utilisez pour livrer.',
        ),
        const SizedBox(height: 20),
        // Sélecteur de véhicule
        Row(
          children: TypeVehicule.values.map((v) {
            final isSelected = widget.data.typeVehicule == v;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => widget.data.typeVehicule = v);
                  widget.onChanged();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.kPrimaryOrange
                        : AppColors.kWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.kPrimaryOrange
                          : AppColors.kGreyLight,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.kPrimaryOrange.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _vehiculeIcon(v),
                        color: isSelected
                            ? AppColors.kWhite
                            : AppColors.kTextSecondary,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _vehiculeLabel(v),
                        style: TextStyle(
                          fontSize: 12,
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
        const SizedBox(height: 28),
        const _SectionHeader(
          icone: Icons.description_outlined,
          titre: 'Documents',
          sousTitre: 'Entrez vos numéros de documents officiels.',
        ),
        const SizedBox(height: 16),
        OzelTextField(
          label: 'Numéro CNI (Carte Nationale d\'Identité)',
          hint: 'Ex: 1234567890',
          controller: _cniCtrl,
          prefixIcon: const Icon(Icons.badge, color: AppColors.kPrimaryOrange),
          keyboardType: TextInputType.number,
          onChanged: (v) {
            widget.data.numeroCni = v;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        OzelTextField(
          label: 'Numéro de permis de conduire',
          hint: 'Ex: BJ-123456',
          controller: _permisCtrl,
          prefixIcon: const Icon(Icons.drive_eta, color: AppColors.kPrimaryOrange),
          onChanged: (v) {
            widget.data.numeroPermis = v;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        _InfoBox(
          icone: Icons.info_outline,
          texte: 'Des photos de vos documents vous seront demandées '
              'lors de l\'activation de votre compte par notre équipe.',
        ),
      ],
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
        return 'Moto';
      case TypeVehicule.velo:
        return 'Vélo';
      case TypeVehicule.voiture:
        return 'Voiture';
    }
  }
}

// ── Étape 3 : Photo de profil ─────────────────────────────────────────────────

class _Etape3 extends StatefulWidget {
  final _InscriptionData data;
  final VoidCallback onChanged;

  const _Etape3({super.key, required this.data, required this.onChanged});

  @override
  State<_Etape3> createState() => _Etape3State();
}

class _Etape3State extends State<_Etape3> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _SectionHeader(
          icone: Icons.camera_alt_rounded,
          titre: 'Photo de profil',
          sousTitre: 'Une photo de vous aide les clients à vous reconnaître.',
        ),
        const SizedBox(height: 32),
        // Avatar mock
        GestureDetector(
          onTap: () {
            setState(() => widget.data.photoAjoutee = true);
            widget.onChanged();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo sélectionnée (simulation MVP)'),
                backgroundColor: AppColors.kGreen,
              ),
            );
          },
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.data.photoAjoutee
                      ? AppColors.kPrimaryOrange
                      : AppColors.kGreyLight,
                  border: Border.all(
                    color: AppColors.kPrimaryOrange,
                    width: 3,
                  ),
                ),
                child: widget.data.photoAjoutee
                    ? const Icon(Icons.person, color: AppColors.kWhite, size: 56)
                    : const Icon(Icons.add_a_photo_outlined,
                        color: AppColors.kGrey, size: 40),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.kPrimaryOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt,
                    color: AppColors.kWhite, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.data.photoAjoutee
              ? 'Photo ajoutée ✓'
              : 'Appuyez pour ajouter une photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.data.photoAjoutee
                ? AppColors.kGreen
                : AppColors.kTextSecondary,
          ),
        ),
        const SizedBox(height: 32),
        // Récapitulatif
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.kWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.kGreyLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Récapitulatif de votre dossier',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.kTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _RecapLigne(
                label: 'Nom',
                valeur:
                    '${widget.data.prenom} ${widget.data.nom}'.trim().isEmpty
                        ? '—'
                        : '${widget.data.prenom} ${widget.data.nom}'.trim(),
              ),
              _RecapLigne(
                label: 'Téléphone',
                valeur: widget.data.telephone.isEmpty
                    ? '—'
                    : formatPhoneDisplay(widget.data.telephone),
              ),
              _RecapLigne(
                label: 'Véhicule',
                valeur: _vehiculeLabel(widget.data.typeVehicule),
              ),
              _RecapLigne(
                label: 'CNI',
                valeur: widget.data.numeroCni.isEmpty ? '—' : widget.data.numeroCni,
              ),
              _RecapLigne(
                label: 'Permis',
                valeur: widget.data.numeroPermis.isEmpty ? '—' : widget.data.numeroPermis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoBox(
          icone: Icons.schedule,
          texte: 'Après soumission, votre dossier sera examiné sous 24–48h. '
              'Un SMS de confirmation vous sera envoyé.',
        ),
      ],
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

class _RecapLigne extends StatelessWidget {
  final String label;
  final String valeur;
  const _RecapLigne({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.kTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.kTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets helpers partagés ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String sousTitre;

  const _SectionHeader({
    required this.icone,
    required this.titre,
    required this.sousTitre,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.kPrimaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icone, color: AppColors.kPrimaryOrange, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sousTitre,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.kTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icone;
  final String texte;

  const _InfoBox({required this.icone, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.kBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: AppColors.kBlue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texte,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.kBlue,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
