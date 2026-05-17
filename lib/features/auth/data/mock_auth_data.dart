// Données mockées pour l'authentification — MVP OZELSERVICES Livreur
import '../../../shared/models/document.dart';
import '../../../shared/models/livreur.dart';

/// Livreur mocké pour les tests et le MVP
final mockLivreur = Livreur(
  id: 'livreur_001',
  nom: 'Mensah',
  prenom: 'Kofi',
  telephone: '+22997112233',
  photoUrl: null,
  typeVehicule: TypeVehicule.moto,
  note: 4.2,
  totalLivraisons: 87,
  estEnLigne: false,
  token: 'mock_jwt_token_abc123',
  documents: [
    const Document(type: TypeDocument.cni, statut: StatutDocument.valide),
    const Document(type: TypeDocument.permis, statut: StatutDocument.valide),
    const Document(
        type: TypeDocument.assurance, statut: StatutDocument.enAttente),
  ],
);

/// OTP fixe pour les tests (en production, généré par le backend)
const String mockOtpCode = '123456';

/// Numéro de téléphone accepté par le mock
const String mockPhoneNumber = '+22997112233';

/// Token de session mocké
const String mockToken = 'mock_jwt_token_abc123';
