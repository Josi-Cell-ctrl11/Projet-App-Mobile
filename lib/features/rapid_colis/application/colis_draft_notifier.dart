import "package:flutter_riverpod/flutter_riverpod.dart";

/// Brouillon Rapid Colis (saisie formulaire avant devis).
class ColisDraft {
  const ColisDraft({
    this.pointA = "",
    this.pointB = "",
    this.weightKg = 1,
    this.distanceKm = 2,
    this.photoPath,
  });

  final String pointA;
  final String pointB;
  final double weightKg;
  final double distanceKm;
  final String? photoPath;

  ColisDraft copyWith({
    String? pointA,
    String? pointB,
    double? weightKg,
    double? distanceKm,
    String? photoPath,
    bool clearPhoto = false,
  }) =>
      ColisDraft(
        pointA: pointA ?? this.pointA,
        pointB: pointB ?? this.pointB,
        weightKg: weightKg ?? this.weightKg,
        distanceKm: distanceKm ?? this.distanceKm,
        photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      );
}

class ColisDraftNotifier extends Notifier<ColisDraft> {
  @override
  ColisDraft build() => const ColisDraft();

  void setPointA(String v) => state = state.copyWith(pointA: v);
  void setPointB(String v) => state = state.copyWith(pointB: v);
  void setWeight(double kg) => state = state.copyWith(weightKg: kg);
  void setDistance(double km) => state = state.copyWith(distanceKm: km);
  void setPhoto(String? path) =>
      state = state.copyWith(photoPath: path, clearPhoto: path == null);

  void reset() => state = const ColisDraft();
}

final colisDraftProvider = NotifierProvider<ColisDraftNotifier, ColisDraft>(
  ColisDraftNotifier.new,
);
