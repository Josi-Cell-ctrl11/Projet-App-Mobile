import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/notifications/fcm_bootstrap.dart";
import "../../../core/theme/app_colors.dart";
import "../../auth/application/auth_session.dart";

/// Ecran profil utilisateur — design moderne.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(user: user),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats ────────────────────────────────────────────────
                  _StatsRow(user: user),
                  const SizedBox(height: 24),

                  // ── Infos personnelles ───────────────────────────────────
                  _SectionLabel("Informations personnelles"),
                  const SizedBox(height: 10),
                  _ModernCard(
                    children: [
                      _Row(
                        icon: Icons.person_rounded,
                        iconColor: AppColors.primary,
                        label: "Prénom",
                        value: user?.firstName.isNotEmpty == true
                            ? user!.firstName
                            : "—",
                      ),
                      _Row(
                        icon: Icons.person_outline_rounded,
                        iconColor: AppColors.primary,
                        label: "Nom",
                        value: user?.lastName.isNotEmpty == true
                            ? user!.lastName
                            : "—",
                      ),
                      _Row(
                        icon: Icons.alternate_email_rounded,
                        iconColor: const Color(0xFF6A1B9A),
                        label: "Pseudo",
                        value: user?.pseudo.isNotEmpty == true
                            ? "@${user!.pseudo}"
                            : "—",
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Coordonnées ──────────────────────────────────────────
                  _SectionLabel("Coordonnées"),
                  const SizedBox(height: 10),
                  _ModernCard(
                    children: [
                      _Row(
                        icon: Icons.phone_android_rounded,
                        iconColor: const Color(0xFF2E7D32),
                        label: "Téléphone",
                        value: user?.phone ?? "—",
                      ),
                      _Row(
                        icon: Icons.chat_rounded,
                        iconColor: const Color(0xFF25D366),
                        label: "WhatsApp",
                        value: user?.whatsapp.isNotEmpty == true
                            ? user!.whatsapp
                            : "—",
                      ),
                      _Row(
                        icon: Icons.email_outlined,
                        iconColor: const Color(0xFFE64A19),
                        label: "Email",
                        value: user?.email?.isNotEmpty == true
                            ? user!.email!
                            : "—",
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Vérification ─────────────────────────────────────────
                  _SectionLabel("Vérification"),
                  const SizedBox(height: 10),
                  _ModernCard(
                    children: [
                      _Row(
                        icon: Icons.badge_rounded,
                        iconColor: const Color(0xFF1565C0),
                        label: "NPI",
                        value: user?.npi.isNotEmpty == true
                            ? user!.npi
                            : "Non renseigné",
                        trailing: user?.npi.isNotEmpty == true
                            ? _Badge(
                                label: "Vérifié",
                                icon: Icons.verified_rounded,
                                color: AppColors.success,
                              )
                            : _Badge(
                                label: "En attente",
                                icon: Icons.schedule_rounded,
                                color: AppColors.warning,
                              ),
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Actions ──────────────────────────────────────────────
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    label: "Modifier le profil",
                    color: AppColors.primary,
                    onTap: () => context.push("/profil/edit"),
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    icon: Icons.receipt_long_rounded,
                    label: "Mes commandes OzelFoods",
                    color: const Color(0xFF1565C0),
                    outlined: true,
                    onTap: () => context.push("/ozelfoods/historique"),
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    icon: Icons.logout_rounded,
                    label: "Se déconnecter",
                    color: Colors.red,
                    outlined: true,
                    onTap: () async {
                      await ref.read(authSessionProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go("/login");
                    },
                  ),
                  const SizedBox(height: 10),
                  // Bouton test Firebase — à retirer en production
                  _ActionButton(
                    icon: Icons.notifications_active_rounded,
                    label: "Voir token FCM (test)",
                    color: Colors.grey,
                    outlined: true,
                    onTap: () => showFcmTokenDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Fond gradient
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFE64A19)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              // Titre
              Positioned(
                top: 52,
                left: 20,
                child: SafeArea(
                  child: const Text(
                    "Mon Profil",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Avatar flottant
        Positioned(
          bottom: -44,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF5F5F7), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              child: Text(
                user?.initials ?? "?",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          // Nom + badge vérifié
          Text(
            user?.displayName ?? "Invité",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
            ),
          ),
          if (user?.pseudo.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text(
              "@${user!.pseudo}",
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Stat points
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatPill(
                icon: Icons.stars_rounded,
                value: "${user?.ozelPoints ?? 0}",
                label: "Points Ozel",
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _StatPill(
                icon: Icons.verified_user_rounded,
                value: user?.npi.isNotEmpty == true ? "Vérifié" : "En attente",
                label: "Statut NPI",
                color: user?.npi.isNotEmpty == true
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

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

// ── Carte moderne ─────────────────────────────────────────────────────────────

class _ModernCard extends StatelessWidget {
  const _ModernCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ── Ligne d'info ──────────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.trailing,
    this.isLast = false,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Widget? trailing;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 66,
            endIndent: 16,
            color: Colors.grey.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}

// ── Badge statut ──────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bouton action ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(icon, size: 18),
              label: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(icon, size: 18),
              label: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
    );
  }
}
