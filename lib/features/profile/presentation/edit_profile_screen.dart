import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../shared/models/app_user.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";
import "../../auth/application/auth_session.dart";

/// Écran d'édition du profil — NPI, WhatsApp, photo, pseudo.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _pseudo;
  late final TextEditingController _whatsapp;
  late final TextEditingController _npi;
  late final TextEditingController _email;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authSessionProvider).user;
    _firstName = TextEditingController(text: user?.firstName ?? "");
    _lastName = TextEditingController(text: user?.lastName ?? "");
    _pseudo = TextEditingController(text: user?.pseudo ?? "");
    _whatsapp = TextEditingController(
        text: user?.whatsapp.isNotEmpty == true ? user!.whatsapp : "+229");
    _npi = TextEditingController(text: user?.npi ?? "");
    _email = TextEditingController(text: user?.email ?? "");
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _pseudo.dispose();
    _whatsapp.dispose();
    _npi.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;

    setState(() => _loading = true);

    final current = ref.read(authSessionProvider).user;
    if (current == null) return;

    final npiValue = _npi.text.trim();
    final isProfileComplete = _firstName.text.trim().isNotEmpty &&
        _lastName.text.trim().isNotEmpty &&
        npiValue.length == 10;

    final updated = current.copyWith(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      pseudo: _pseudo.text.trim(),
      whatsapp: _whatsapp.text.trim(),
      npi: npiValue,
      email: _email.text.trim(),
      isProfileComplete: isProfileComplete,
      // name est mis à jour pour rester cohérent
      name: "${_firstName.text.trim()} ${_lastName.text.trim()}".trim(),
    );

    await ref.read(authSessionProvider.notifier).saveUser(updated);

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profil mis à jour ✓"),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.black,
        title: const Text(
          "Modifier mon profil",
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.black),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      ref.watch(authSessionProvider).user?.initials ?? "?",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Identité ─────────────────────────────────────────────────────
            _SectionLabel("Identité"),
            const SizedBox(height: 10),
            OzelTextField(
              controller: _firstName,
              label: "Prénom",
              hint: "Ex: Kouassi",
              prefixIcon: Icons.person_rounded,
            ),
            const SizedBox(height: 12),
            OzelTextField(
              controller: _lastName,
              label: "Nom de famille",
              hint: "Ex: Ahouansou",
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            OzelTextField(
              controller: _pseudo,
              label: "Pseudo (facultatif)",
              hint: "Ex: monpseudo",
              prefixIcon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 20),

            // ── Contact ───────────────────────────────────────────────────────
            _SectionLabel("Contact"),
            const SizedBox(height: 10),
            OzelTextField(
              controller: _whatsapp,
              label: "Numéro WhatsApp",
              hint: "+229 97 00 00 00",
              prefixIcon: Icons.chat_rounded,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[+\d]")),
              ],
            ),
            const SizedBox(height: 12),
            OzelTextField(
              controller: _email,
              label: "Email (facultatif)",
              hint: "votre@email.com",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // ── Vérification identité ────────────────────────────────────────
            _SectionLabel("Vérification d'identité"),
            const SizedBox(height: 10),
            OzelTextField(
              controller: _npi,
              label: "NPI (Numéro Personnel d'Identification)",
              hint: "10 chiffres",
              prefixIcon: Icons.badge_rounded,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 6),
            const Text(
              "Le NPI est requis pour accéder à certains services OZELSERVICES.",
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),

            OzelPrimaryButton(
              label: _loading ? "Enregistrement..." : "Enregistrer le profil",
              enabled: !_loading,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    // image_picker est dans le pubspec — simulation pour MVP
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Upload photo — disponible après intégration image_picker"),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
}
