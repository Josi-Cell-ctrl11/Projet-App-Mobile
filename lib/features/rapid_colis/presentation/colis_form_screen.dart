import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/rapid_colis_pricing.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";
import "../application/colis_draft_notifier.dart";

/// Formulaire Rapid Colis — UI moderne avec prix en temps réel.
class ColisFormScreen extends ConsumerStatefulWidget {
  const ColisFormScreen({super.key});

  @override
  ConsumerState<ColisFormScreen> createState() => _ColisFormScreenState();
}

class _ColisFormScreenState extends ConsumerState<ColisFormScreen> {
  final _a = TextEditingController(text: "Ganhi — marché Dantokpa");
  final _b = TextEditingController(text: "Akpakpa — en face de la pharmacie");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final d = ref.read(colisDraftProvider);
      _a.text = d.pointA.isNotEmpty ? d.pointA : _a.text;
      _b.text = d.pointB.isNotEmpty ? d.pointB : _b.text;
    });
  }

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
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
    if (_a.text.trim().isEmpty || _b.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Renseignez les points A et B."),
          backgroundColor: AppColors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    context.push("/rapid-colis/devis");
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(colisDraftProvider);
    final price = RapidColisPricing.quote(
      distanceKm: draft.distanceKm,
      weightKg: draft.weightKg,
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
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Header bleu ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.white,
                  size: 36,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Envoi de colis",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Livraison rapide à Cotonou & environs",
                        style: TextStyle(
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

          // ── Prix en temps réel ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        "Prix estimé",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.fcfa(price),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
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
                    Icons.calculate_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Aperçu trajet (sans CustomPaint) ──────────────────────────────
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
                    const Icon(
                      Icons.map_rounded,
                      size: 16,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Aperçu du trajet",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                const SizedBox(height: 12),
                _MapPin(
                  label: "A",
                  color: AppColors.success,
                  text: draft.pointA.isNotEmpty
                      ? draft.pointA
                      : "Point de départ",
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    width: 2,
                    height: 16,
                    color: AppColors.disabled,
                  ),
                ),
                _MapPin(
                  label: "B",
                  color: AppColors.primary,
                  text: draft.pointB.isNotEmpty
                      ? draft.pointB
                      : "Point d'arrivée",
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Adresses ───────────────────────────────────────────────────────
          const _SectionLabel(
            icon: Icons.place_outlined,
            label: "Adresses",
          ),
          const SizedBox(height: 10),
          OzelTextField(
            controller: _a,
            label: "Point A — Ramassage",
            prefixIcon: Icons.flag_rounded,
          ),
          const SizedBox(height: 12),
          OzelTextField(
            controller: _b,
            label: "Point B — Livraison",
            prefixIcon: Icons.place_rounded,
          ),

          const SizedBox(height: 20),

          // ── Détails colis ──────────────────────────────────────────────────
          const _SectionLabel(
            icon: Icons.tune_rounded,
            label: "Détails du colis",
          ),
          const SizedBox(height: 12),

          _SliderCard(
            icon: Icons.scale_rounded,
            label: "Poids",
            value: "${draft.weightKg.toStringAsFixed(1)} kg",
            child: Slider(
              value: draft.weightKg.clamp(0.5, 30),
              min: 0.5,
              max: 30,
              divisions: 59,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withValues(alpha: 0.15),
              label: "${draft.weightKg.toStringAsFixed(1)} kg",
              onChanged: (v) =>
                  ref.read(colisDraftProvider.notifier).setWeight(v),
            ),
          ),

          const SizedBox(height: 12),

          _SliderCard(
            icon: Icons.route_rounded,
            label: "Distance estimée",
            value: "${draft.distanceKm.toStringAsFixed(1)} km",
            child: Slider(
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
          ),

          const SizedBox(height: 16),

          // ── Photo ──────────────────────────────────────────────────────────
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
                        ? "Ajouter une photo du colis (optionnel)"
                        : "Photo sélectionnée ✓",
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

          // ── Info tarification ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "1 000 FCFA jusqu'à 3 km · +150 FCFA/km · +500 FCFA/kg au-delà de 5 kg",
                    style: TextStyle(
                      color: AppColors.primary,
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
            label: "Calculer le prix",
            onPressed: _next,
          ),
        ],
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

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.child,
  });
  final IconData icon;
  final String label;
  final String value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.label,
    required this.color,
    required this.text,
  });
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
