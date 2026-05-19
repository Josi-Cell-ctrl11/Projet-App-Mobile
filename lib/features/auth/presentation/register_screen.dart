import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "package:uuid/uuid.dart";

import "../../../core/theme/app_colors.dart";
import "../../../shared/models/app_user.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";
import "../application/auth_session.dart";

/// Inscription en 2 etapes style Gozem/Yango.
/// Etape 1 : Informations personnelles (prenom, nom, pseudo, photo)
/// Etape 2 : Coordonnees et verification (tel, WhatsApp, NPI, CGU)
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _etape = 1;

  // ── Etape 1 ────────────────────────────────────────────────────────────────
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _pseudo = TextEditingController();
  String? _avatarPath;

  // ── Etape 2 ────────────────────────────────────────────────────────────────
  final _phone = TextEditingController(text: "+229");
  final _whatsapp = TextEditingController(text: "+229");
  final _npi = TextEditingController();
  bool _cguAccepted = false;

  // ── Erreurs ────────────────────────────────────────────────────────────────
  String? _errFirstName;
  String? _errLastName;
  String? _errPseudo;
  String? _errPhone;
  String? _errWhatsapp;
  String? _errNpi;
  String? _errCgu;

  bool _loading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _pseudo.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _npi.dispose();
    super.dispose();
  }

  // ── Validation etape 1 ─────────────────────────────────────────────────────
  bool _validerEtape1() {
    setState(() {
      _errFirstName =
          _firstName.text.trim().isEmpty ? "Le prenom est obligatoire" : null;
      _errLastName =
          _lastName.text.trim().isEmpty ? "Le nom est obligatoire" : null;
      _errPseudo =
          _pseudo.text.trim().isEmpty ? "Le pseudo est obligatoire" : null;
    });
    return _errFirstName == null &&
        _errLastName == null &&
        _errPseudo == null;
  }

  // ── Validation etape 2 ─────────────────────────────────────────────────────
  bool _validerEtape2() {
    final phoneRegex = RegExp(r'^\+229\d{8}$');
    final npiRegex = RegExp(r'^\d{10}$');

    setState(() {
      _errPhone = !phoneRegex.hasMatch(_phone.text.trim())
          ? "Format invalide (+229XXXXXXXX)"
          : null;
      _errWhatsapp = !phoneRegex.hasMatch(_whatsapp.text.trim())
          ? "Format invalide (+229XXXXXXXX)"
          : null;
      _errNpi = !npiRegex.hasMatch(_npi.text.trim())
          ? "Le NPI doit contenir exactement 10 chiffres"
          : null;
      _errCgu = !_cguAccepted ? "Vous devez accepter les CGU" : null;
    });
    return _errPhone == null &&
        _errWhatsapp == null &&
        _errNpi == null &&
        _errCgu == null;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _avatarPath = file.path);
  }

  void _continuer() {
    if (_validerEtape1()) setState(() => _etape = 2);
  }

  Future<void> _sInscrire() async {
    if (!_validerEtape2()) return;
    setState(() => _loading = true);

    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();

    final user = AppUser(
      id: const Uuid().v4(),
      name: "$firstName $lastName",
      firstName: firstName,
      lastName: lastName,
      pseudo: _pseudo.text.trim(),
      phone: _phone.text.trim(),
      whatsapp: _whatsapp.text.trim(),
      npi: _npi.text.trim(),
      avatarUrl: _avatarPath,
      isProfileComplete: true,
      walletBalanceFcfa: 5000,
      ozelPoints: 500,
    );

    await ref.read(authSessionProvider.notifier).saveUser(user);
    setState(() => _loading = false);
    if (!mounted) return;
    context.go("/accueil");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Barre de progression ─────────────────────────────────────────
            _ProgressBar(etape: _etape),

            Expanded(
              child: _etape == 1
                  ? _buildEtape1()
                  : _buildEtape2(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Etape 1 : Informations personnelles ────────────────────────────────────
  Widget _buildEtape1() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          "Qui etes-vous ?",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Etape 1 sur 2 — Informations personnelles",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 28),

        // Photo de profil
        Center(
          child: GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  backgroundImage: _avatarPath != null
                      ? null
                      : null,
                  child: _avatarPath == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            "Photo de profil (optionnelle)",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Prenom
        OzelTextField(
          controller: _firstName,
          label: "Prenom *",
          prefixIcon: Icons.person_outline_rounded,
        ),
        if (_errFirstName != null) _ErrMsg(_errFirstName!),
        const SizedBox(height: 12),

        // Nom
        OzelTextField(
          controller: _lastName,
          label: "Nom de famille *",
          prefixIcon: Icons.person_outline_rounded,
        ),
        if (_errLastName != null) _ErrMsg(_errLastName!),
        const SizedBox(height: 12),

        // Pseudo
        OzelTextField(
          controller: _pseudo,
          label: "Pseudo (ex: @monpseudo) *",
          prefixIcon: Icons.alternate_email_rounded,
        ),
        if (_errPseudo != null) _ErrMsg(_errPseudo!),

        const SizedBox(height: 32),

        OzelPrimaryButton(
          label: "Continuer",
          onPressed: _continuer,
        ),

        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => context.go("/login"),
            child: const Text(
              "Deja un compte ? Se connecter",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  // ── Etape 2 : Coordonnees et verification ──────────────────────────────────
  Widget _buildEtape2() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _etape = 1),
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.black,
            ),
            const SizedBox(width: 8),
            const Text(
              "Vos coordonnees",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.only(left: 48),
          child: Text(
            "Etape 2 sur 2 — Coordonnees et verification",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(height: 24),

        // Telephone
        OzelTextField(
          controller: _phone,
          label: "Telephone (+229XXXXXXXX) *",
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_android_rounded,
        ),
        if (_errPhone != null) _ErrMsg(_errPhone!),
        const SizedBox(height: 12),

        // WhatsApp
        OzelTextField(
          controller: _whatsapp,
          label: "WhatsApp (+229XXXXXXXX) *",
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.chat_rounded,
        ),
        if (_errWhatsapp != null) _ErrMsg(_errWhatsapp!),
        const SizedBox(height: 4),
        const Text(
          "Peut etre identique au numero de telephone",
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        // NPI
        OzelTextField(
          controller: _npi,
          label: "NPI — Numero Personnel d'Identification *",
          keyboardType: TextInputType.number,
          prefixIcon: Icons.badge_rounded,
        ),
        if (_errNpi != null) _ErrMsg(_errNpi!),
        const SizedBox(height: 4),
        const Text(
          "10 chiffres — Votre NPI beninois",
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),

        const SizedBox(height: 20),

        // CGU
        GestureDetector(
          onTap: () => setState(() => _cguAccepted = !_cguAccepted),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _cguAccepted,
                onChanged: (v) => setState(() => _cguAccepted = v ?? false),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "J'accepte les Conditions Generales d'Utilisation d'OZELSERVICES",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_errCgu != null) _ErrMsg(_errCgu!),

        const SizedBox(height: 28),

        OzelPrimaryButton(
          label: _loading ? "Inscription..." : "S'inscrire",
          enabled: !_loading,
          onPressed: _sInscrire,
        ),
      ],
    );
  }
}

// ── Widgets helpers ───────────────────────────────────────────────────────────

/// Barre de progression etape 1/2 ou 2/2
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.etape});
  final int etape;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delivery_dining_rounded,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "OZELSERVICES",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              Text(
                "Etape $etape / 2",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: etape / 2,
              backgroundColor: AppColors.surface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Message d'erreur inline
class _ErrMsg extends StatelessWidget {
  const _ErrMsg(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 11,
        ),
      ),
    );
  }
}
