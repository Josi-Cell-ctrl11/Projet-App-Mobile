/// Règles OzelFoods : minimum panier, annulation si non accepté, retard livreur.
abstract final class FoodBusinessRules {
  static bool meetsMinimumOrder(double subtotalFcfa, double minimumFcfa) =>
      subtotalFcfa >= minimumFcfa;

  /// Points de remboursement si livreur en retard (10 % du sous-total).
  static int lateRefundPoints(double subtotalFcfa, double percent) =>
      (subtotalFcfa * percent).floor();
}
