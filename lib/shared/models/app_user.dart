/// Utilisateur connecte OZELSERVICES (mock / persistance locale).
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.firstName = "",
    this.lastName = "",
    this.pseudo = "",
    this.whatsapp = "",
    this.npi = "",
    this.avatarUrl,
    this.isProfileComplete = false,
    this.walletBalanceFcfa = 0,
    this.ozelPoints = 0,
  });

  final String id;

  /// Nom complet (legacy — conserve pour compatibilite)
  final String name;
  final String phone;
  final String? email;

  // ── Nouveaux champs inscription style Gozem/Yango ──────────────────────────
  /// Prenom de l'utilisateur
  final String firstName;

  /// Nom de famille
  final String lastName;

  /// Pseudo/Surnom (ex: @monpseudo)
  final String pseudo;

  /// Numero WhatsApp format beninois (+229...)
  final String whatsapp;

  /// Numero Personnel d'Identification (NPI Benin — 10 chiffres)
  final String npi;

  /// URL photo de profil (optionnelle)
  final String? avatarUrl;

  /// true si l'inscription est complete (toutes les etapes validees)
  final bool isProfileComplete;

  // ── Wallet & points ────────────────────────────────────────────────────────
  final double walletBalanceFcfa;
  final int ozelPoints;

  /// Nom affiche : firstName + lastName si disponibles, sinon name
  String get displayName =>
      (firstName.isNotEmpty && lastName.isNotEmpty)
          ? "$firstName $lastName"
          : name;

  /// Initiales pour l'avatar
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return "${firstName[0]}${lastName[0]}".toUpperCase();
    }
    if (name.isNotEmpty) return name[0].toUpperCase();
    return "?";
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "pseudo": pseudo,
        "whatsapp": whatsapp,
        "npi": npi,
        "avatarUrl": avatarUrl,
        "isProfileComplete": isProfileComplete,
        "walletBalanceFcfa": walletBalanceFcfa,
        "ozelPoints": ozelPoints,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json["id"] as String,
        name: json["name"] as String,
        phone: json["phone"] as String,
        email: json["email"] as String?,
        firstName: json["firstName"] as String? ?? "",
        lastName: json["lastName"] as String? ?? "",
        pseudo: json["pseudo"] as String? ?? "",
        whatsapp: json["whatsapp"] as String? ?? "",
        npi: json["npi"] as String? ?? "",
        avatarUrl: json["avatarUrl"] as String?,
        isProfileComplete: json["isProfileComplete"] as bool? ?? false,
        walletBalanceFcfa:
            (json["walletBalanceFcfa"] as num?)?.toDouble() ?? 0,
        ozelPoints: (json["ozelPoints"] as num?)?.toInt() ?? 0,
      );

  AppUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? firstName,
    String? lastName,
    String? pseudo,
    String? whatsapp,
    String? npi,
    String? avatarUrl,
    bool? isProfileComplete,
    double? walletBalanceFcfa,
    int? ozelPoints,
  }) =>
      AppUser(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        pseudo: pseudo ?? this.pseudo,
        whatsapp: whatsapp ?? this.whatsapp,
        npi: npi ?? this.npi,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isProfileComplete: isProfileComplete ?? this.isProfileComplete,
        walletBalanceFcfa: walletBalanceFcfa ?? this.walletBalanceFcfa,
        ozelPoints: ozelPoints ?? this.ozelPoints,
      );
}
