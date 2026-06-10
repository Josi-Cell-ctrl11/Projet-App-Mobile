import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Ecran d'accueil Ozel Event — evenementiel au Benin.
/// Système de devis uniquement (pas de prix fixes).
class OzelEventHomeScreen extends ConsumerStatefulWidget {
  const OzelEventHomeScreen({super.key});

  @override
  ConsumerState<OzelEventHomeScreen> createState() => _OzelEventHomeScreenState();
}

class _OzelEventHomeScreenState extends ConsumerState<OzelEventHomeScreen> {
  static const Color _color = Color(0xFF6A1B9A);

  // Formulaire de demande de devis
  String? _selectedEventType;
  final Set<String> _selectedPrestations = {};
  DateTime? _dateEvenement;
  final TextEditingController _lieuCtrl = TextEditingController();
  final TextEditingController _invitesCtrl = TextEditingController();
  final TextEditingController _whatsappCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF6A1B9A))),
        child: child!,
      ),
    );
    if (d != null) setState(() => _dateEvenement = d);
  }

  @override
  void dispose() {
    _lieuCtrl.dispose();
    _invitesCtrl.dispose();
    _whatsappCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _demanderDevis() {
    if (_selectedEventType == null ||
        _selectedPrestations.isEmpty ||
        _dateEvenement == null ||
        _lieuCtrl.text.isEmpty ||
        _invitesCtrl.text.isEmpty ||
        _whatsappCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Confirmation
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
              '✅ Votre demande a été envoyée !',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Notre équipe vous contactera sous 2h sur WhatsApp\nau ${_whatsappCtrl.text} pour discuter de votre projet.',
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
              _resetForm();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedEventType = null;
      _selectedPrestations.clear();
      _dateEvenement = null;
      _lieuCtrl.clear();
      _invitesCtrl.clear();
      _whatsappCtrl.clear();
      _notesCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/accueil');
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: CustomScrollView(
          slivers: [
            // ── Header violet ────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: _color,
              foregroundColor: AppColors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.go('/accueil'),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Icon(Icons.event_available_rounded,
                            size: 48, color: Colors.white70),
                        SizedBox(height: 8),
                        Text(
                          'Ozel Event',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Organisez votre evenement au Benin',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text('Ozel Event',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Type d'evenement ─────────────────────────────────────
                    const Text(
                      'Type d\'evenement *',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _EventTypeChip(
                          emoji: '💍',
                          label: 'Mariage',
                          selected: _selectedEventType == 'mariage',
                          onTap: () => setState(() => _selectedEventType = 'mariage'),
                        ),
                        _EventTypeChip(
                          emoji: '🎂',
                          label: 'Anniversaire / Baptême',
                          selected: _selectedEventType == 'anniversaire',
                          onTap: () => setState(() => _selectedEventType = 'anniversaire'),
                        ),
                        _EventTypeChip(
                          emoji: '💼',
                          label: 'Conférence / Séminaire',
                          selected: _selectedEventType == 'conference',
                          onTap: () => setState(() => _selectedEventType = 'conference'),
                        ),
                        _EventTypeChip(
                          emoji: '🏛️',
                          label: 'Réunion / Atelier',
                          selected: _selectedEventType == 'reunion',
                          onTap: () => setState(() => _selectedEventType = 'reunion'),
                        ),
                        _EventTypeChip(
                          emoji: '🎭',
                          label: 'Activité culturelle / Politique',
                          selected: _selectedEventType == 'culturel',
                          onTap: () => setState(() => _selectedEventType = 'culturel'),
                        ),
                        _EventTypeChip(
                          emoji: '🎊',
                          label: 'Autre',
                          selected: _selectedEventType == 'autre',
                          onTap: () => setState(() => _selectedEventType = 'autre'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Prestations ────────────────────────────────────────────
                    const Text(
                      'Prestations souhaitées *',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black),
                    ),
                    const SizedBox(height: 12),
                    _PrestationCheckbox(
                      label: 'Sonorisation',
                      selected: _selectedPrestations.contains('sonorisation'),
                      onTap: () {
                        setState(() {
                          if (_selectedPrestations.contains('sonorisation')) {
                            _selectedPrestations.remove('sonorisation');
                          } else {
                            _selectedPrestations.add('sonorisation');
                          }
                        });
                      },
                    ),
                    _PrestationCheckbox(
                      label: 'Hôtesses d\'accueil',
                      selected: _selectedPrestations.contains('hotesses'),
                      onTap: () {
                        setState(() {
                          if (_selectedPrestations.contains('hotesses')) {
                            _selectedPrestations.remove('hotesses');
                          } else {
                            _selectedPrestations.add('hotesses');
                          }
                        });
                      },
                    ),
                    _PrestationCheckbox(
                      label: 'Traiteur / Restauration',
                      selected: _selectedPrestations.contains('traiteur'),
                      onTap: () {
                        setState(() {
                          if (_selectedPrestations.contains('traiteur')) {
                            _selectedPrestations.remove('traiteur');
                          } else {
                            _selectedPrestations.add('traiteur');
                          }
                        });
                      },
                    ),
                    _PrestationCheckbox(
                      label: 'Décoration',
                      selected: _selectedPrestations.contains('decoration'),
                      onTap: () {
                        setState(() {
                          if (_selectedPrestations.contains('decoration')) {
                            _selectedPrestations.remove('decoration');
                          } else {
                            _selectedPrestations.add('decoration');
                          }
                        });
                      },
                    ),
                    _PrestationCheckbox(
                      label: 'Sécurité événement',
                      selected: _selectedPrestations.contains('securite'),
                      onTap: () {
                        setState(() {
                          if (_selectedPrestations.contains('securite')) {
                            _selectedPrestations.remove('securite');
                          } else {
                            _selectedPrestations.add('securite');
                          }
                        });
                      },
                    ),
                    _PrestationCheckbox(
                      label: 'Photographe / Vidéaste',
                      selected: _selectedPrestations.contains('photo'),
                      onTap: () {
                        setState(() {
                          if (_selectedPrestations.contains('photo')) {
                            _selectedPrestations.remove('photo');
                          } else {
                            _selectedPrestations.add('photo');
                          }
                        });
                      },
                    ),
                    _PrestationCheckbox(
                      label: 'Chef de projet OZEL',
                      selected: _selectedPrestations.contains('chef'),
                      onTap: () {
                        setState(() {
                          if (_selectedPrestations.contains('chef')) {
                            _selectedPrestations.remove('chef');
                          } else {
                            _selectedPrestations.add('chef');
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Détails événement ───────────────────────────────────────
                    const Text(
                      'Détails de l\'evenement *',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black),
                    ),
                    const SizedBox(height: 12),
                    // Date — date picker, pas de saisie libre
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.disabled),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: Color(0xFF6A1B9A), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _dateEvenement == null
                                  ? 'Date de l\'événement *'
                                  : '${_dateEvenement!.day.toString().padLeft(2, '0')}/${_dateEvenement!.month.toString().padLeft(2, '0')}/${_dateEvenement!.year}',
                              style: TextStyle(
                                color: _dateEvenement == null
                                    ? AppColors.textSecondary
                                    : AppColors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _lieuCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Lieu (ville + quartier)',
                        hintText: 'Ex: Cotonou, Fidjrossè',
                        prefixIcon: Icon(Icons.location_on_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Invités — chiffres uniquement, max 5 chiffres
                    TextField(
                      controller: _invitesCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Nombre d\'invités estimé',
                        hintText: 'Ex: 150',
                        prefixIcon: Icon(Icons.people_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // WhatsApp — formatter automatique
                    TextField(
                      controller: _whatsappCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneBeninInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Numéro WhatsApp *',
                        hintText: '0166272826',
                        prefixText: '+229 ',
                        prefixStyle: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(Icons.chat_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes / précisions',
                        hintText: 'Dites-nous en plus sur votre projet...',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Bouton ───────────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _demanderDevis,
                        style: FilledButton.styleFrom(
                          backgroundColor: _color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Demander un devis',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/ozel-event/reservations'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _color,
                          side: const BorderSide(color: Color(0xFF6A1B9A)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.list_alt_rounded),
                        label: const Text('Mes demandes',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTypeChip extends StatelessWidget {
  const _EventTypeChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6A1B9A) : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF6A1B9A) : AppColors.disabled,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrestationCheckbox extends StatelessWidget {
  const _PrestationCheckbox({
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
                color: selected ? const Color(0xFF6A1B9A) : AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected ? const Color(0xFF6A1B9A) : AppColors.disabled,
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
