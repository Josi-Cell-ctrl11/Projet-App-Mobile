import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../auth/application/auth_session.dart";

/// Ecran profil utilisateur — affiche tous les champs du nouveau AppUser.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).user;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── Header avec photo de profil ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.white.withValues(alpha: 0.2),
                      child: user?.avatarUrl != null
                          ? null
                          : Text(
                              user?.initials ?? "?",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    // Nom complet
                    Text(
                      user?.displayName ?? "Invite",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    // Pseudo
                    if (user?.pseudo.isNotEmpty == true)
                      Text(
                        "@${user!.pseudo}",
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            title: const Text(
              "Mon profil",
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Wallet & Points ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.account_balance_wallet_rounded,
                          label: "OzelWallet",
                          value: Formatters.fcfa(
                              user?.walletBalanceFcfa ?? 0),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.stars_rounded,
                          label: "Points Ozel",
                          value: "${user?.ozelPoints ?? 0} pts",
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Informations personnelles ──────────────────────────────
                  const _SectionTitle("Informations personnelles"),
                  const SizedBox(height: 10),

                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.person_rounded,
                        label: "Prenom",
                        value: user?.firstName.isNotEmpty == true
                            ? user!.firstName
                            : "—",
                      ),
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: "Nom",
                        value: user?.lastName.isNotEmpty == true
                            ? user!.lastName
                            : "—",
                      ),
                      _InfoRow(
                        icon: Icons.alternate_email_rounded,
                        label: "Pseudo",
                        value: user?.pseudo.isNotEmpty == true
                            ? "@${user!.pseudo}"
                            : "—",
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Coordonnees ────────────────────────────────────────────
                  const _SectionTitle("Coordonnees"),
                  const SizedBox(height: 10),

                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.phone_android_rounded,
                        label: "Telephone",
                        value: user?.phone ?? "—",
                      ),
                      _InfoRow(
                        icon: Icons.chat_rounded,
                        label: "WhatsApp",
                        value: user?.whatsapp.isNotEmpty == true
                            ? user!.whatsapp
                            : "—",
                      ),
                      if (user?.email != null)
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: "Email",
                          value: user!.email!,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Verification NPI ───────────────────────────────────────
                  const _SectionTitle("Verification"),
                  const SizedBox(height: 10),

                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.badge_rounded,
                        label: "NPI",
                        value: user?.npi.isNotEmpty == true
                            ? user!.npi
                            : "Non renseigne",
                        trailing: user?.npi.isNotEmpty == true
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded,
                                        color: AppColors.success, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      "Verifie",
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Bouton modifier profil ─────────────────────────────────
                  OzelOutlinedButton(
                    label: "Modifier le profil",
                    onPressed: () => context.go("/register"),
                  ),

                  const SizedBox(height: 12),

                  // ── Bouton deconnexion ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(authSessionProvider.notifier)
                            .logout();
                        if (!context.mounted) return;
                        context.go("/login");
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        "Se deconnecter",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets helpers ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    e.value,
                    if (e.key < children.length - 1)
                      const Divider(
                          height: 1, indent: 52, color: AppColors.surface),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
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
                  ),
                ),
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
    );
  }
}
