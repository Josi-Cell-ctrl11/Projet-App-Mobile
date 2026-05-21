import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../core/utils/rapid_colis_pricing.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";
import "../application/colis_draft_notifier.dart";

const Color _orange = Color(0xFFFF6B35);
const Color _lightGray = Color(0xFFF8F8F8);
const Color _darkGray = Color(0xFF333333);
const Color _lightOrange = Color(0xFFFFF3EE);

/// Formulaire Rapid Colis — logique rapport client Mai 2026 :
/// - Pas de saisie de poids (sera pese par le livreur sur place)
/// - Champ "Qui paie ?" : Expediteur ou Destinataire
/// - Mode Coursier universel
/// - Message paiement avant remise
class ColisFormScreen extends ConsumerStatefulWidget {
  const ColisFormScreen({super.key});

  @override
  ConsumerState<ColisFormScreen> createState() => _ColisFormScreenState();
}

class _ColisFormScreenState extends ConsumerState<ColisFormScreen> {
  final _a = TextEditingController(text: "Ganhi — marche Dantokpa");
  final _b = TextEditingController(text: "Akpakpa — en face de la pharmacie");
  final _destPrenom = TextEditingController();
  final _destNom = TextEditingController();
  final _destTel = TextEditingController();
  final _descCoursier = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final d = ref.read(colisDraftProvider);
      if (d.pointA.isNotEmpty) _a.text = d.pointA;
      if (d.pointB.isNotEmpty) _b.text = d.pointB;
      if (d.destinatairePrenom.isNotEmpty) _destPrenom.text = d.destinatairePrenom;
      if (d.destinataireNom.isNotEmpty) _destNom.text = d.destinataireNom;
      if (d.destinataireTelephone.isNotEmpty) _destTel.text = d.destinataireTelephone;
      if (d.descriptionCoursier.isNotEmpty)
        _descCoursier.text = d.descriptionCoursier;
    });
  }

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _destPrenom.dispose();
    _destNom.dispose();
    _destTel.dispose();
    _descCoursier.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    ref.read(colisDraftProvider.notifier).setPhoto(file.path);
    setState(() {});
  }

  void _next() {
    final notifier = ref.read(colisDraftProvider.notifier);
    notifier.setPointA(_a.text.trim());
    notifier.setPointB(_b.text.trim());
    notifier.setDestinatairePrenom(_destPrenom.text.trim());
    notifier.setDestinataireNom(_destNom.text.trim());
    notifier.setDestinataireTelephone(_destTel.text.trim());
    notifier.setDescriptionCoursier(_descCoursier.text.trim());

    if (_a.text.trim().isEmpty || _b.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Renseignez les points A et B."),
          backgroundColor: AppColors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_destPrenom.text.trim().length < 2 || _destNom.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Le prénom et le nom doivent contenir au moins 2 caractères."),
          backgroundColor: AppColors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (!_destTel.text.trim().startsWith('+229')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Le téléphone doit commencer par +229."),
          backgroundColor: AppColors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    context.push("/rapid-colis/devis");
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(colisDraftProvider);
    // Prix estimatif base sur la distance uniquement (poids inconnu)
    final priceEstim = RapidColisPricing.quote(
      distanceKm: draft.distanceKm,
      weightKg: 1, // poids par defaut pour estimation
    );

    return Scaffold(
      backgroundColor: _lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkGray),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Rapid Colis",
          style: TextStyle(
              fontWeight: FontWeight.w800, color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Trajet ────────────────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Trajet",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                OzelTextField(
                  controller: _a,
                  label: "Point A — Ramassage / Départ",
                  prefixIcon: Icons.flag_rounded,
                ),
                const SizedBox(height: 12),
                OzelTextField(
                  controller: _b,
                  label: "Point B — Livraison / Destination",
                  prefixIcon: Icons.place_rounded,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.route_rounded,
                        size: 16, color: _darkGray),
                    const SizedBox(width: 6),
                    const Text(
                      "Distance estimée",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: _darkGray,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "${draft.distanceKm.toStringAsFixed(1)} km",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Slider(
                  value: draft.distanceKm.clamp(0.5, 25),
                  min: 0.5,
                  max: 25,
                  divisions: 49,
                  activeColor: _orange,
                  inactiveColor: Colors.grey.shade300,
                  label: "${draft.distanceKm.toStringAsFixed(1)} km",
                  onChanged: (v) =>
                      ref.read(colisDraftProvider.notifier).setDistance(v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Destinataire ───────────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 18, color: _darkGray),
                    const SizedBox(width: 8),
                    const Text(
                      "Destinataire",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OzelTextField(
                  controller: _destPrenom,
                  label: "Prénom du destinataire *",
                  prefixIcon: Icons.person_rounded,
                ),
                const SizedBox(height: 12),
                OzelTextField(
                  controller: _destNom,
                  label: "Nom du destinataire *",
                  prefixIcon: Icons.person_rounded,
                ),
                const SizedBox(height: 12),
                OzelTextField(
                  controller: _destTel,
                  label: "Numéro de téléphone du destinataire *",
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Qui paie ? ─────────────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Qui paie la livraison ?",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PayeurCard(
                        icon: Icons.credit_card_rounded,
                        label: "J'expédie et je paie",
                        selected: draft.payeur == PayeurColis.expediteur,
                        onTap: () =>
                            ref.read(colisDraftProvider.notifier).setPayeur(PayeurColis.expediteur),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PayeurCard(
                        icon: Icons.inventory_2_rounded,
                        label: "Le destinataire paie",
                        selected: draft.payeur == PayeurColis.destinataire,
                        onTap: () =>
                            ref.read(colisDraftProvider.notifier).setPayeur(PayeurColis.destinataire),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Message légal ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _lightOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: _orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Le paiement doit être effectué avant la remise du colis.",
                    style: TextStyle(
                      color: _orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Bouton ─────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _next,
              style: FilledButton.styleFrom(
                backgroundColor: _orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Calculer le prix",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets helpers ──────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PayeurCard extends StatelessWidget {
  const _PayeurCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? _lightOrange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _orange : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? _orange : _darkGray, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? _orange : Colors.black,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
