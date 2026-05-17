// Chaînes de caractères localisées en français
/// Toutes les chaînes de l'application OZELSERVICES Livreur
class AppStrings {
  AppStrings._();

  // --- Général ---
  static const String appName = 'OZELSERVICES Livreur';
  static const String ok = 'OK';
  static const String annuler = 'Annuler';
  static const String confirmer = 'Confirmer';
  static const String retour = 'Retour';
  static const String erreur = 'Erreur';
  static const String chargement = 'Chargement...';

  // --- Authentification ---
  static const String connexion = 'Connexion';
  static const String deconnexion = 'Déconnexion';
  static const String numeroDeTelephone = 'Numéro de téléphone';
  static const String entrezVotreNumero = 'Entrez votre numéro (+229...)';
  static const String envoyerCode = 'Envoyer le code';
  static const String codeOtp = 'Code OTP';
  static const String entrezCodeOtp = 'Entrez le code à 6 chiffres';
  static const String validerCode = 'Valider le code';
  static const String renvoyerCode = 'Renvoyer le code';
  static const String codeExpire = 'Code expiré';
  static const String codeIncorrect = 'Code incorrect, veuillez réessayer';
  static const String numeroInvalide = 'Numéro de téléphone invalide';
  static const String tempsRestant = 'Temps restant : ';

  // --- Dashboard ---
  static const String tableauDeBord = 'Tableau de bord';
  static const String enLigne = 'En ligne';
  static const String horsLigne = 'Hors ligne';
  static const String commandesDuJour = 'Commandes du jour';
  static const String gainsDuJour = 'Gains du jour';
  static const String voirCommandesDisponibles = 'Voir commandes disponibles';

  // --- Commandes ---
  static const String commandes = 'Commandes';
  static const String aucuneCommande = 'Aucune commande disponible pour le moment';
  static const String accepter = 'Accepter';
  static const String refuser = 'Refuser';
  static const String detailCommande = 'Détail de la commande';
  static const String pickup = 'Point de collecte';
  static const String livraison = 'Adresse de livraison';
  static const String client = 'Client';
  static const String appelerClient = 'Appeler le client';
  static const String jesuisAuPickup = 'Je suis au pickup';
  static const String enRoute = 'En route';
  static const String livre = 'Livré';
  static const String ozelFoods = 'OzelFoods';
  static const String rapidColis = 'Rapid Colis';

  // --- Navigation GPS ---
  static const String navigation = 'Navigation';
  static const String distanceRestante = 'Distance restante';
  static const String tempsEstime = 'Temps estimé';
  static const String gpsIndisponible = 'GPS indisponible';
  static const String activerGps = 'Activer le GPS';

  // --- Confirmation OTP livraison ---
  static const String confirmationLivraison = 'Confirmation de livraison';
  static const String entrezCodeClient = 'Entrez le code fourni par le client';
  static const String livraisonConfirmee = 'Livraison confirmée !';
  static const String montantGagne = 'Montant gagné';
  static const String otpLivraisonIncorrect = 'Code OTP incorrect';

  // --- Gains ---
  static const String gains = 'Gains';
  static const String soldeDisponible = 'Solde disponible';
  static const String gainsAujourdhui = "Gains aujourd'hui";
  static const String gainsSemaine = 'Gains cette semaine';
  static const String gainsMois = 'Gains ce mois';
  static const String historique = 'Historique';
  static const String demanderRetrait = 'Demander un retrait';
  static const String numeromomo = 'Numéro MoMo';
  static const String montantRetrait = 'Montant du retrait';
  static const String retraitEnvoye = 'Demande de retrait envoyée, paiement sous 24h';
  static const String montantMinimum = 'Montant minimum : 1 000 FCFA';
  static const String soldeInsuffisant = 'Solde insuffisant';
  static const String enAttente = 'En attente';
  static const String credite = 'Crédité';

  // --- Profil ---
  static const String profil = 'Profil';
  static const String moto = 'Moto';
  static const String velo = 'Vélo';
  static const String voiture = 'Voiture';
  static const String documents = 'Documents';
  static const String cni = 'CNI';
  static const String permis = 'Permis de conduire';
  static const String assurance = 'Assurance';
  static const String valide = 'Valide';
  static const String enAttenteValidation = 'En attente de validation';
  static const String manquant = 'Manquant';
  static const String avertissementNote =
      'Votre note est inférieure à 3.5. Risque de suspension.';
  static const String totalLivraisons = 'Total livraisons';

  // --- Erreurs réseau ---
  static const String erreurReseau = 'Erreur réseau. Veuillez réessayer.';
  static const String erreurServeur = 'Erreur serveur. Veuillez réessayer plus tard.';

  // --- Suspension ---
  static const String suspensionTitre = 'Compte suspendu temporairement';
  static const String suspensionMessage =
      'Vous avez refusé 3 commandes consécutives. Votre compte est suspendu pendant 1 heure.';
}
