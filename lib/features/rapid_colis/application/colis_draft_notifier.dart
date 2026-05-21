import "package:flutter_riverpod/flutter_riverpod.dart";

/// Qui prend en charge les frais de livraison.
enum PayeurColis { expediteur, destinataire }

/// Mode d'envoi : colis standard ou coursier universel.
enum ModeColis { colis, coursier }

/// Brouillon Rapid Colis (saisie formulaire avant devis).
class ColisDraft {
  const ColisDraft({
    this.pointA = "",
    this.pointB = "",
    this.destinatairePrenom = "",
    this.destinataireNom = "",
    this.destinataireTelephone = "",
    // Le poids n'est plus saisi par le client — il sera mesure par le livreur.
    // On garde distanceKm pour le calcul de devis.
    this.distanceKm = 2,
    this.photoPath,
    this.payeur = PayeurColis.expediteur,
    this.mode = ModeColis.colis,
    this.descriptionCoursier = "",
  });

  final String pointA;
  final String pointB;
  final String destinatairePrenom;
  final String destinataireNom;
  final String destinataireTelephone;

  /// Distance estimee en km (saisie par le client, confirmee par le livreur).
  final double distanceKm;

  final String? photoPath;

  /// Qui paie les frais de livraison.
  final PayeurColis payeur;

  /// Mode : colis standard ou coursier universel.
  final ModeColis mode;

  /// Description de la course (mode coursier uniquement).
  final String descriptionCoursier;

  ColisDraft copyWith({
    String? pointA,
    String? pointB,
    String? destinatairePrenom,
    String? destinataireNom,
    String? destinataireTelephone,
    double? distanceKm,
    String? photoPath,
    bool clearPhoto = false,
    PayeurColis? payeur,
    ModeColis? mode,
    String? descriptionCoursier,
  }) =>
      ColisDraft(
        pointA: pointA ?? this.pointA,
        pointB: pointB ?? this.pointB,
        destinatairePrenom: destinatairePrenom ?? this.destinatairePrenom,
        destinataireNom: destinataireNom ?? this.destinataireNom,
        destinataireTelephone:
            destinataireTelephone ?? this.destinataireTelephone,
        distanceKm: distanceKm ?? this.distanceKm,
        photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
        payeur: payeur ?? this.payeur,
        mode: mode ?? this.mode,
        descriptionCoursier: descriptionCoursier ?? this.descriptionCoursier,
      );
}

class ColisDraftNotifier extends Notifier<ColisDraft> {
  @override
  ColisDraft build() => const ColisDraft();

  void setPointA(String v) => state = state.copyWith(pointA: v);
  void setPointB(String v) => state = state.copyWith(pointB: v);
  void setDestinatairePrenom(String v) =>
      state = state.copyWith(destinatairePrenom: v);
  void setDestinataireNom(String v) =>
      state = state.copyWith(destinataireNom: v);
  void setDestinataireTelephone(String v) =>
      state = state.copyWith(destinataireTelephone: v);
  void setDistance(double km) => state = state.copyWith(distanceKm: km);
  void setPhoto(String? path) =>
      state = state.copyWith(photoPath: path, clearPhoto: path == null);
  void setPayeur(PayeurColis p) => state = state.copyWith(payeur: p);
  void setMode(ModeColis m) => state = state.copyWith(mode: m);
  void setDescriptionCoursier(String v) =>
      state = state.copyWith(descriptionCoursier: v);

  void reset() => state = const ColisDraft();
}

final colisDraftProvider = NotifierProvider<ColisDraftNotifier, ColisDraft>(
  ColisDraftNotifier.new,
);
