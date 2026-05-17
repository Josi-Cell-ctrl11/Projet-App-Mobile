/// Statuts de commande OzelFoods (suivi temps quasi réel — mock Timer côté UI).
enum FoodOrderStatus {
  preparing,
  riderAssigned,
  onTheWay,
  delivered,
}

extension FoodOrderStatusFr on FoodOrderStatus {
  String get labelFr {
    switch (this) {
      case FoodOrderStatus.preparing:
        return "En préparation";
      case FoodOrderStatus.riderAssigned:
        return "Livreur assigné";
      case FoodOrderStatus.onTheWay:
        return "En route";
      case FoodOrderStatus.delivered:
        return "Livré";
    }
  }
}
