import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../shared/models/colis_shipment.dart";

/// Colis actif pour l’écran de suivi GPS (mock).
class ActiveColisNotifier extends Notifier<ColisShipment?> {
  @override
  ColisShipment? build() => null;

  void setShipment(ColisShipment shipment) => state = shipment;

  void clear() => state = null;
}

final activeColisProvider = NotifierProvider<ActiveColisNotifier, ColisShipment?>(
  ActiveColisNotifier.new,
);
