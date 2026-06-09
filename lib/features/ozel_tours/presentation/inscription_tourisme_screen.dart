import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Ecran d'inscription au tourisme local.
class InscriptionTourismeScreen extends ConsumerStatefulWidget {
  const InscriptionTourismeScreen({super.key});

  @override
  ConsumerState<InscriptionTourismeScreen> createState() =>
      _InscriptionTourismeScreenState();
}

class _InscriptionTourismeScreenState
    extends ConsumerState<InscriptionTourismeScreen> {
  static const Color _color = Color(0xFF00695C);

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _interestCtrl = TextEditingController();
  final Set<String> _selectedActivities = {};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _interestCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _selectedActivities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            const Text(
              '✅ Inscription réussie !',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Notre équipe vous contactera sous 24h pour organiser votre expérience touristique.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/ozel-tours');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/ozel-tours');
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: _color,
          foregroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go('/ozel-tours'),
          ),
          title: const Text(
            'Inscription Tourisme',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF004D40)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.explore_rounded, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rejoignez notre communauté',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Découvrez le Bénin authentique',
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
            const SizedBox(height: 24),

            // Formulaire
            const Text(
              'Vos informations *',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                hintText: 'Votre nom',
                prefixIcon: Icon(Icons.person_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [PhoneBeninInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                hintText: '01 97 90 90 98',
                prefixText: '+229 ',
                prefixStyle: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icon(Icons.phone_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'votre@email.com',
                prefixIcon: Icon(Icons.email_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Activités
            const Text(
              'Activités souhaitées *',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            _ActivityCheckbox(
              label: 'Visites de villages traditionnels',
              selected: _selectedActivities.contains('villages'),
              onTap: () {
                setState(() {
                  if (_selectedActivities.contains('villages')) {
                    _selectedActivities.remove('villages');
                  } else {
                    _selectedActivities.add('villages');
                  }
                });
              },
            ),
            _ActivityCheckbox(
              label: 'Ateliers artisanaux',
              selected: _selectedActivities.contains('ateliers'),
              onTap: () {
                setState(() {
                  if (_selectedActivities.contains('ateliers')) {
                    _selectedActivities.remove('ateliers');
                  } else {
                    _selectedActivities.add('ateliers');
                  }
                });
              },
            ),
            _ActivityCheckbox(
              label: 'Festivals culturels',
              selected: _selectedActivities.contains('festivals'),
              onTap: () {
                setState(() {
                  if (_selectedActivities.contains('festivals')) {
                    _selectedActivities.remove('festivals');
                  } else {
                    _selectedActivities.add('festivals');
                  }
                });
              },
            ),
            _ActivityCheckbox(
              label: 'Cuisine locale',
              selected: _selectedActivities.contains('cuisine'),
              onTap: () {
                setState(() {
                  if (_selectedActivities.contains('cuisine')) {
                    _selectedActivities.remove('cuisine');
                  } else {
                    _selectedActivities.add('cuisine');
                  }
                });
              },
            ),
            _ActivityCheckbox(
              label: 'Randonnées nature',
              selected: _selectedActivities.contains('randonnees'),
              onTap: () {
                setState(() {
                  if (_selectedActivities.contains('randonnees')) {
                    _selectedActivities.remove('randonnees');
                  } else {
                    _selectedActivities.add('randonnees');
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // Notes
            TextField(
              controller: _interestCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Centres d\'intérêt',
                hintText: 'Dites-nous ce qui vous intéresse particulièrement...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text('S\'inscrire',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ActivityCheckbox extends StatelessWidget {
  const _ActivityCheckbox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF00695C) : AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected ? const Color(0xFF00695C) : AppColors.disabled,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
