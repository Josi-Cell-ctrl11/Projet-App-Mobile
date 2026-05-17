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
  final _nomDest = TextEditingController();
  final _telDest = TextEditingController();
  final _descCoursier = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final d = ref.read(colisDraftProvider);
      if (d.pointA.isNotEmpty) _a.text = d.pointA;
      if (d.pointB.isNotEmpty) _b.text = d.pointB;
      if (d.nomDestinataire.isNotEmpty) _nomDest.text = d.nomDestinataire;
      if (d.telephoneDestinataire.isNotEmpty)
        _telDest.text = d.telephoneDestinataire;
      if (d.descriptionCoursier.isNotEmpty)
        _descCoursier.text = d.descriptionCoursier;
    });
  }

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _nomDest.dispose();
    _telDest.dispose();
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
    notifier.setNomDestinataire(_nomDest.text.trim());
    notifier.setTelephoneDestinataire(_telDest.text.trim());
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Rapid Colis",
          style: TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Choix du mode ──────────────────────────────────────────────────
          _ModeSelector(
            selected: draft.mode,
            onChanged: (m) =>
                ref.read(colisDraftProvider.notifier).setMode(m),
          ),

          const SizedBox(height: 16),

          // ── Header ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: draft.mode == ModeColis.colis
                    ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
                    : [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  draft.mode == ModeColis.colis
                      ? Icons.inventory_2_rounded
                      : Icons.directions_bike_rounded,
                  color: AppColors.white,
                  size: 36,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.mode == ModeColis.colis
                            ? "Envoi de colis"
                            : "Coursier universel",
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        draft.mode == ModeColis.colis
                            ? "Le livreur pesera le colis sur place"
                            : "Le livreur va chercher l'article pour vous",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Prix estimatif ─────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Prix estimatif",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "a partir de ${Formatters.fcfa(priceEstim)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        "Prix final apres pesee par le livreur",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.scale_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Message paiement avant remise ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFB71C1C).withValues(alpha: 0.25)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_rounded,
                    color: Color(0xFFB71C1C), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Le paiement doit etre effectue avant la remise du colis.",
                    style: TextStyle(
                      color: Color(0xFFB71C1C),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Adresses ───────────────────────────────────────────────────────
          const _SectionLabel(
              icon: Icons.place_outlined, label: "Adresses"),
          const SizedBox(height: 10),
          OzelTextField(
            controller: _a,
            label: "Point A — Ramassage / Depart",
            prefixIcon: Icons.flag_rounded,
          ),
          const SizedBox(height: 12),
          OzelTextField(
            controller: _b,
            label: "Point B — Livraison / Destination",
            prefixIcon: Icons.place_rounded,
          ),

          const SizedBox(height: 16),

          // ── Apercu trajet ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBBCEF8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.route_rounded,
                        size: 16, color: Color(0xFF1565C0)),
                    const SizedBox(width: 6),
                    const Text(
                      "Distance estimee",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${draft.distanceKm.toStringAsFixed(1)} km",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF1565C0),
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
                  activeColor: const Color(0xFF1565C0),
                  inactiveColor:
                      const Color(0xFF1565C0).withValues(alpha: 0.15),
                  label: "${draft.distanceKm.toStringAsFixed(1)} km",
                  onChanged: (v) =>
                      ref.read(colisDraftProvider.notifier).setDistance(v),
                ),
                const SizedBox(height: 4),
                _MapPin(
                  label: "A",
                  color: AppColors.success,
                  text: draft.pointA.isNotEmpty
                      ? draft.pointA
                      : "Point de depart",
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                      width: 2, height: 14, color: AppColors.disabled),
                ),
                _MapPin(
                  label: "B",
                  color: const Color(0xFF1565C0),
                  text: draft.pointB.isNotEmpty
                      ? draft.pointB
                      : "Point d'arrivee",
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Destinataire ───────────────────────────────────────────────────
          const _SectionLabel(
              icon: Icons.person_outline_rounded,
              label: "Destinataire"),
          const SizedBox(height: 10),
          OzelTextField(
            controller: _nomDest,
            label: "Nom du destinataire",
            prefixIcon: Icons.person_rounded,
          ),
          const SizedBox(height: 12),
          OzelTextField(
            controller: _telDest,
            label: "Telephone du destinataire",
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 20),

          // ── Qui paie ? ─────────────────────────────────────────────────────
          const _SectionLabel(
              icon: Icons.payments_rounded, label: "Qui paie la livraison ?"),
          const SizedBox(height: 10),
          _PayeurSelector(
            selected: draft.payeur,
            onChanged: (p) =>
                ref.read(colisDraftProvider.notifier).setPayeur(p),
          ),

          const SizedBox(height: 20),

          // ── Description (mode coursier) ────────────────────────────────────
          if (draft.mode == ModeColis.coursier) ...[
            const _SectionLabel(
                icon: Icons.description_rounded,
                label: "Description de la course"),
            const SizedBox(height: 10),
            OzelTextField(
              controller: _descCoursier,
              label: "Ex: Aller chercher un repas chez Chez Adja, Ganhi",
              maxLines: 3,
              prefixIcon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 20),
          ],

          // ── Photo ──────────────────────────────────────────────────────────
          if (draft.mode == ModeColis.colis) ...[
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: draft.photoPath != null
                        ? AppColors.success
                        : AppColors.disabled,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      draft.photoPath != null
                          ? Icons.check_circle_rounded
                          : Icons.photo_camera_outlined,
                      color: draft.photoPath != null
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      draft.photoPath == null
                          ? "Photo du colis (optionnel)"
                          : "Photo selectionnee",
                      style: TextStyle(
                        color: draft.photoPath != null
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Info pesee ─────────────────────────────────────────────────────
          if (draft.mode == ModeColis.colis)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.25)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.scale_rounded,
                      color: AppColors.success, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Le livreur pesera votre colis a l'arrivee avec son pese-colis. "
                      "Vous validerez le poids sur l'application avant le calcul du tarif final.",
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          OzelPrimaryButton(
            label: "Voir le devis",
            onPressed: _next,
          ),
        ],
      ),
    );
  }
}

// ─── Mode Selector ────────────────────────────────────────────────────────────
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selected, required this.onChanged});
  final ModeColis selected;
  final ValueChanged<ModeColis> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeChip(
            icon: Icons.inventory_2_rounded,
            label: "Colis",
            subtitle: "Envoi standard",
            selected: selected == ModeColis.colis,
            color: const Color(0xFF1565C0),
            onTap: () => onChanged(ModeColis.colis),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeChip(
            icon: Icons.directions_bike_rounded,
            label: "Coursier",
            subtitle: "Course universelle",
            selected: selected == ModeColis.coursier,
            color: AppColors.primary,
            onTap: () => onChanged(ModeColis.coursier),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.disabled,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? color : AppColors.textSecondary,
                size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? color : AppColors.black,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payeur Selector ──────────────────────────────────────────────────────────
class _PayeurSelector extends StatelessWidget {
  const _PayeurSelector({required this.selected, required this.onChanged});
  final PayeurColis selected;
  final ValueChanged<PayeurColis> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PayeurOption(
          icon: Icons.person_rounded,
          label: "Moi (expediteur)",
          subtitle: "Je paie maintenant avant la collecte",
          selected: selected == PayeurColis.expediteur,
          onTap: () => onChanged(PayeurColis.expediteur),
        ),
        const SizedBox(height: 8),
        _PayeurOption(
          icon: Icons.person_pin_rounded,
          label: "Le destinataire",
          subtitle: "Il paie a la reception — le livreur attend la confirmation",
          selected: selected == PayeurColis.destinataire,
          onTap: () => onChanged(PayeurColis.destinataire),
        ),
        if (selected == PayeurColis.destinataire) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Le livreur ne remettra le colis qu'apres confirmation "
                    "du paiement par le destinataire. En cas de non-paiement, "
                    "le colis sera depose au commissariat.",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PayeurOption extends StatelessWidget {
  const _PayeurOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.disabled,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.primary : AppColors.black,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets helpers ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin(
      {required this.label, required this.color, required this.text});
  final String label;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
