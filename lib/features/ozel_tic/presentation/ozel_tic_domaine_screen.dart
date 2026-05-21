import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Ecran achat nom de domaine OzelTic.
class OzelTicDomaineScreen extends StatefulWidget {
  const OzelTicDomaineScreen({super.key});

  @override
  State<OzelTicDomaineScreen> createState() => _OzelTicDomaineScreenState();
}

class _OzelTicDomaineScreenState extends State<OzelTicDomaineScreen> {
  static const Color _color = Color(0xFF1565C0);
  final _nomCtrl = TextEditingController();
  String _nomRecherche = '';

  static const Map<String, double> _extensions = {
    '.bj': 25000,
    '.com': 15000,
    '.net': 12000,
    '.org': 10000,
  };

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  void _commander(String ext, double prix) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Commande $_nomRecherche$ext (${Formatters.fcfa(prix)}/an) — Paiement mock confirme !'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nom de domaine',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Recherche
          const Text('Rechercher un domaine',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.black)),
          const SizedBox(height: 12),
          TextField(
            controller: _nomCtrl,
            onChanged: (v) => setState(() => _nomRecherche = v.trim()),
            decoration: InputDecoration(
              hintText: 'Ex: monsite, ozelservices...',
              filled: true,
              fillColor: AppColors.white,
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF1565C0)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF1565C0), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_nomRecherche.isNotEmpty) ...[
            const Text('Extensions disponibles',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.black)),
            const SizedBox(height: 12),
            ..._extensions.entries.map((e) => _ExtensionCard(
                  nom: _nomRecherche,
                  extension: e.key,
                  prix: e.value,
                  color: _color,
                  onCommander: () => _commander(e.key, e.value),
                )),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.language_rounded,
                      size: 48, color: Color(0xFF1565C0)),
                  SizedBox(height: 12),
                  Text(
                    'Tapez le nom de votre domaine pour voir les extensions disponibles',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Info tarifs
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tarifs annuels',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 10),
                ..._extensions.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text(Formatters.fcfa(e.value) + '/an',
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtensionCard extends StatelessWidget {
  const _ExtensionCard({
    required this.nom,
    required this.extension,
    required this.prix,
    required this.color,
    required this.onCommander,
  });
  final String nom, extension;
  final double prix;
  final Color color;
  final VoidCallback onCommander;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.language_rounded,
                color: Color(0xFF1565C0), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$nom$extension',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Disponible',
                          style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Text(Formatters.fcfa(prix) + '/an',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onCommander,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Commander',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
