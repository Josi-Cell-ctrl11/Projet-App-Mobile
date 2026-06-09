/**
 * Script de seed Firestore — OZELSERVICES Livreur
 * Injecte les commandes de test (Cotonou, Bénin) et un livreur de test.
 *
 * Usage :
 *   node scripts/seed_firestore.mjs
 *
 * Prérequis :
 *   - Être connecté : firebase login (déjà fait)
 *   - GOOGLE_APPLICATION_CREDENTIALS ou Application Default Credentials actifs
 *   - npm install firebase-admin (déjà fait)
 */

import { initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';

// ── Init Firebase Admin avec les credentials de la session active ────────────
initializeApp({
  credential: applicationDefault(),
  projectId: 'ozelservice-livreur',
});

const db = getFirestore();

// ── Données de seed ───────────────────────────────────────────────────────────

const commandes = [
  {
    id: 'cmd_001',
    type: 'ozelFoods',
    clientNom: 'Adjoua Koffi',
    clientTelephone: '+22997223344',
    adressePickup: {
      libelle: 'Restaurant Le Bénin, Cadjehoun, Cotonou',
      latitude: 6.3654,
      longitude: 2.4183,
    },
    adresseLivraison: {
      libelle: 'Quartier Akpakpa, Rue des Cocotiers, Cotonou',
      latitude: 6.3702,
      longitude: 2.4350,
    },
    descriptionArticles: 'Riz sauce graine x2, Poulet braisé x1, Jus de gingembre x2',
    distanceKm: 3.2,
    tempsEstimeMinutes: 15,
    montantTotal: 2000,
    partLivreur: 1400,
    statut: 'disponible',
    otpCode: '847291',
    livreurId: null,
    createdAt: Timestamp.now(),
  },
  {
    id: 'cmd_002',
    type: 'rapidColis',
    clientNom: 'Brice Ahouansou',
    clientTelephone: '+22996334455',
    adressePickup: {
      libelle: 'Marché Dantokpa, Cotonou',
      latitude: 6.3601,
      longitude: 2.4270,
    },
    adresseLivraison: {
      libelle: 'Fidjrossè Plage, Cotonou',
      latitude: 6.3480,
      longitude: 2.3890,
    },
    descriptionArticles: 'Colis fragile — Pièces électroniques (1 carton)',
    distanceKm: 5.8,
    tempsEstimeMinutes: 22,
    montantTotal: 1500,
    partLivreur: 1050,
    statut: 'disponible',
    otpCode: '362819',
    livreurId: null,
    createdAt: Timestamp.fromMillis(Date.now() - 5 * 60 * 1000),
  },
  {
    id: 'cmd_003',
    type: 'ozelFoods',
    clientNom: 'Fatou Diallo',
    clientTelephone: '+22997445566',
    adressePickup: {
      libelle: 'Maquis Chez Tonton, Haie Vive, Cotonou',
      latitude: 6.3720,
      longitude: 2.4100,
    },
    adresseLivraison: {
      libelle: 'Quartier Agla, Cotonou',
      latitude: 6.3810,
      longitude: 2.3950,
    },
    descriptionArticles: 'Attiéké poisson x1, Alloco x2, Boisson fraîche x3',
    distanceKm: 2.5,
    tempsEstimeMinutes: 12,
    montantTotal: 2500,
    partLivreur: 1750,
    statut: 'disponible',
    otpCode: '519374',
    livreurId: null,
    createdAt: Timestamp.fromMillis(Date.now() - 1 * 60 * 1000),
  },
  {
    id: 'cmd_004',
    type: 'rapidColis',
    clientNom: 'Rodrigue Hounkpatin',
    clientTelephone: '+22995556677',
    adressePickup: {
      libelle: 'Zone Ganhi, Cotonou',
      latitude: 6.3580,
      longitude: 2.4320,
    },
    adresseLivraison: {
      libelle: 'Cadjehoun, Cotonou',
      latitude: 6.3660,
      longitude: 2.4150,
    },
    descriptionArticles: 'Documents administratifs — Enveloppe scellée (urgent)',
    distanceKm: 1.8,
    tempsEstimeMinutes: 10,
    montantTotal: 1000,
    partLivreur: 700,
    statut: 'disponible',
    otpCode: '728463',
    livreurId: null,
    createdAt: Timestamp.fromMillis(Date.now() - 30 * 1000),
  },
  {
    id: 'cmd_005',
    type: 'ozelFoods',
    clientNom: 'Mariama Sow',
    clientTelephone: '+22994667788',
    adressePickup: {
      libelle: 'Fast Food Délices, Boulevard Saint-Michel, Cotonou',
      latitude: 6.3640,
      longitude: 2.4200,
    },
    adresseLivraison: {
      libelle: 'Cotonou Centre, près de la Cathédrale',
      latitude: 6.3690,
      longitude: 2.4260,
    },
    descriptionArticles: 'Burger x2, Frites x2, Milkshake chocolat x1, Salade x1',
    distanceKm: 1.2,
    tempsEstimeMinutes: 8,
    montantTotal: 3500,
    partLivreur: 2450,
    statut: 'disponible',
    otpCode: '193847',
    livreurId: null,
    createdAt: Timestamp.now(),
  },
];

// Livreur de test (sera remplacé par le vrai UID Firebase Auth à la première connexion)
const livreurTest = {
  id: 'livreur_test_001',
  nom: 'Mensah',
  prenom: 'Kofi',
  telephone: '+22997112233',
  photoUrl: null,
  typeVehicule: 'moto',
  note: 4.2,
  totalLivraisons: 87,
  estEnLigne: false,
  documents: [
    { type: 'cni', statut: 'valide', dateExpiration: null },
    { type: 'permis', statut: 'valide', dateExpiration: null },
    { type: 'assurance', statut: 'enAttente', dateExpiration: null },
  ],
  updatedAt: Timestamp.now(),
};

// Gains de test pour le livreur de test
const gainsTest = {
  soldeDisponible: 8750,
  gainsAujourdhui: 4200,
  gainsSemaine: 18900,
  gainsMois: 67200,
};

const historiqueTest = [
  { commandeId: 'cmd_005', type: 'ozelFoods', montantGagne: 2450, statutPaiement: 'enAttente', date: Timestamp.fromMillis(Date.now() - 1 * 3600 * 1000) },
  { commandeId: 'cmd_004', type: 'rapidColis', montantGagne: 700, statutPaiement: 'enAttente', date: Timestamp.fromMillis(Date.now() - 3 * 3600 * 1000) },
  { commandeId: 'cmd_003', type: 'ozelFoods', montantGagne: 1050, statutPaiement: 'enAttente', date: Timestamp.fromMillis(Date.now() - 5 * 3600 * 1000) },
  { commandeId: 'cmd_h01', type: 'ozelFoods', montantGagne: 1750, statutPaiement: 'credite', date: Timestamp.fromMillis(Date.now() - 26 * 3600 * 1000) },
  { commandeId: 'cmd_h02', type: 'rapidColis', montantGagne: 1400, statutPaiement: 'credite', date: Timestamp.fromMillis(Date.now() - 28 * 3600 * 1000) },
];

// ── Fonctions d'écriture ───────────────────────────────────────────────────────

async function seedCommandes() {
  console.log('📦 Injection des commandes...');
  const batch = db.batch();
  for (const cmd of commandes) {
    const { id, ...data } = cmd;
    batch.set(db.collection('commandes').doc(id), data);
  }
  await batch.commit();
  console.log(`  ✅ ${commandes.length} commandes injectées`);
}

async function seedLivreurTest() {
  console.log('👤 Injection du livreur de test...');
  const { id, ...data } = livreurTest;
  await db.collection('livreurs').doc(id).set(data);
  console.log(`  ✅ Livreur test (${livreurTest.prenom} ${livreurTest.nom}) injecté`);
}

async function seedGainsTest() {
  console.log('💰 Injection des gains de test...');
  const gainsRef = db.collection('gains').doc(livreurTest.id);
  await gainsRef.set(gainsTest);

  // Sous-collection historique
  const batch = db.batch();
  for (const h of historiqueTest) {
    batch.set(gainsRef.collection('historique').doc(h.commandeId), h);
  }
  await batch.commit();
  console.log(`  ✅ Gains + ${historiqueTest.length} entrées historique injectées`);
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  console.log('\n🚀 Seed Firestore — OZELSERVICES Livreur\n');
  console.log(`   Projet : ozelservice-livreur`);
  console.log(`   Environnement : production (Firestore réel)\n`);

  try {
    await seedCommandes();
    await seedLivreurTest();
    await seedGainsTest();
    console.log('\n✅ Seed terminé avec succès !\n');
    process.exit(0);
  } catch (err) {
    console.error('\n❌ Erreur pendant le seed :', err.message);
    console.error(err);
    process.exit(1);
  }
}

main();
