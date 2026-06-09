#!/bin/bash
# Seed Firestore — OZELSERVICES Livreur
# Usage : bash scripts/seed.sh
# Pré-requis : firebase CLI connecté (firebase login)

PROJECT="ozelservice-livreur"
echo "🔥 Seed Firestore — projet $PROJECT"

# ── Commandes ─────────────────────────────────────────────────────────────────

echo ""
echo "📦 Injection des commandes..."

seed_commande() {
  local ID=$1
  local DATA=$2
  firebase firestore:documents:set \
    --project="$PROJECT" \
    "commandes/$ID" \
    "$DATA"
}

seed_commande "cmd_001" '{
  "type": {"stringValue": "ozelFoods"},
  "clientNom": {"stringValue": "Adjoua Koffi"},
  "clientTelephone": {"stringValue": "+22997223344"},
  "adressePickup": {"mapValue": {"fields": {
    "libelle": {"stringValue": "Restaurant Le Bénin, Cadjehoun, Cotonou"},
    "latitude": {"doubleValue": 6.3654},
    "longitude": {"doubleValue": 2.4183}
  }}},
  "adresseLivraison": {"mapValue": {"fields": {
    "libelle": {"stringValue": "Quartier Akpakpa, Rue des Cocotiers, Cotonou"},
    "latitude": {"doubleValue": 6.3702},
    "longitude": {"doubleValue": 2.4350}
  }}},
  "descriptionArticles": {"stringValue": "Riz sauce graine x2, Poulet braisé x1, Jus x2"},
  "distanceKm": {"doubleValue": 3.2},
  "tempsEstimeMinutes": {"integerValue": 15},
  "montantTotal": {"doubleValue": 2000},
  "partLivreur": {"doubleValue": 1400},
  "statut": {"stringValue": "disponible"},
  "otpCode": {"stringValue": "847291"},
  "livreurId": {"nullValue": null}
}'

seed_commande "cmd_002" '{
  "type": {"stringValue": "rapidColis"},
  "clientNom": {"stringValue": "Brice Ahouansou"},
  "clientTelephone": {"stringValue": "+22996334455"},
  "adressePickup": {"mapValue": {"fields": {
    "libelle": {"stringValue": "Marché Dantokpa, Cotonou"},
    "latitude": {"doubleValue": 6.3601},
    "longitude": {"doubleValue": 2.4270}
  }}},
  "adresseLivraison": {"mapValue": {"fields": {
    "libelle": {"stringValue": "Fidjrossè Plage, Cotonou"},
    "latitude": {"doubleValue": 6.3480},
    "longitude": {"doubleValue": 2.3890}
  }}},
  "descriptionArticles": {"stringValue": "Colis fragile — Pièces électroniques (1 carton)"},
  "distanceKm": {"doubleValue": 5.8},
  "tempsEstimeMinutes": {"integerValue": 22},
  "montantTotal": {"doubleValue": 1500},
  "partLivreur": {"doubleValue": 1050},
  "statut": {"stringValue": "disponible"},
  "otpCode": {"stringValue": "362819"},
  "livreurId": {"nullValue": null}
}'

seed_commande "cmd_003" '{
  "type": {"stringValue": "ozelFoods"},
  "clientNom": {"stringValue": "Fatou Diallo"},
  "clientTelephone": {"stringValue": "+22997445566"},
  "adressePickup": {"mapValue": {"fields": {
    "libelle": {"stringValue": "Maquis Chez Tonton, Haie Vive, Cotonou"},
    "latitude": {"doubleValue": 6.3720},
    "longitude": {"doubleValue": 2.4100}
  }}},
  "adresseLivraison": {"mapValue": {"fields": {
    "libelle": {"stringValue": "Quartier Agla, Cotonou"},
    "latitude": {"doubleValue": 6.3810},
    "longitude": {"doubleValue": 2.3950}
  }}},
  "descriptionArticles": {"stringValue": "Attiéké poisson x1, Alloco x2, Boisson x3"},
  "distanceKm": {"doubleValue": 2.5},
  "tempsEstimeMinutes": {"integerValue": 12},
  "montantTotal": {"doubleValue": 2500},
  "partLivreur": {"doubleValue": 1750},
  "statut": {"stringValue": "disponible"},
  "otpCode": {"stringValue": "519374"},
  "livreurId": {"nullValue": null}
}'

seed_commande "cmd_004" '{
  "type": {"stringValue": "rapidColis"},
  "clientNom": {"stringValue": "Rodrigue Hounkpatin"},
  "clientTelephone": {"stringValue": "+22995556677"},
  "adressePickup": {"mapValue": {"fields": {
    "libelle": {"stringValue": "Zone Ganhi, Cotonou"},
    "latitude": {"doubleValue": 6.3580},
    "longitude": {"doubleValue": 2.4320}
  }}},
  "adresseLivraison": {"mapValue": {"fields": {
    "libelle": {"stringValue": "Cadjehoun, Cotonou"},
    "latitude": {"doubleValue": 6.3660},
    "longitude": {"doubleValue": 2.4150}
  }}},
  "descriptionArticles": {"stringValue": "Documents administratifs — Enveloppe scellée"},
  "distanceKm": {"doubleValue": 1.8},
  "tempsEstimeMinutes": {"integerValue": 10},
  "montantTotal": {"doubleValue": 1000},
  "partLivreur": {"doubleValue": 700},
  "statut": {"stringValue": "disponible"},
  "otpCode": {"stringValue": "728463"},
  "livreurId": {"nullValue": null}
}'

seed_commande "cmd_005" '{
  "type": {"stringValue": "ozelFoods"},
  "clientNom": {"stringValue": "Mariama Sow"},
  "clientTelephone": {"stringValue": "+22994667788"},
  "adressePickup": {"mapValue": {"fields": {
    "libelle": {"stringValue": "Fast Food Délices, Boulevard Saint-Michel"},
    "latitude": {"doubleValue": 6.3640},
    "longitude": {"doubleValue": 2.4200}
  }}},
  "adresseLivraison": {"mapValue": {"fields": {
    "libelle": {"stringValue": "Cotonou Centre, près de la Cathédrale"},
    "latitude": {"doubleValue": 6.3690},
    "longitude": {"doubleValue": 2.4260}
  }}},
  "descriptionArticles": {"stringValue": "Burger x2, Frites x2, Milkshake x1"},
  "distanceKm": {"doubleValue": 1.2},
  "tempsEstimeMinutes": {"integerValue": 8},
  "montantTotal": {"doubleValue": 3500},
  "partLivreur": {"doubleValue": 2450},
  "statut": {"stringValue": "disponible"},
  "otpCode": {"stringValue": "193847"},
  "livreurId": {"nullValue": null}
}'

echo "  ✅ 5 commandes injectées"

# ── Index Firestore ────────────────────────────────────────────────────────────

echo ""
echo "📑 Déploiement des index..."
firebase deploy --only firestore:indexes --project="$PROJECT"

echo ""
echo "✅ Seed terminé !"
echo ""
echo "📱 Pour tester l'app :"
echo "   flutter run"
echo "   Connexion : +22997112233 | OTP : voir Firebase Console → Auth"
