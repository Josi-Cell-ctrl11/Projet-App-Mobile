import "package:flutter/material.dart";

import "../../core/theme/app_colors.dart";

/// Widget reutilisable "Bientot disponible" pour les services en attente.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 60, color: color),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "Bientot disponible",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Vous serez notifie des que $title sera disponible !",
                        ),
                        backgroundColor: color,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.notifications_active_rounded),
                  label: const Text(
                    "Etre notifie",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
