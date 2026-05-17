/// Utilisateur connecté (mock / persistance locale).
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.walletBalanceFcfa = 0,
    this.ozelPoints = 0,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final double walletBalanceFcfa;
  final int ozelPoints;

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "walletBalanceFcfa": walletBalanceFcfa,
        "ozelPoints": ozelPoints,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json["id"] as String,
        name: json["name"] as String,
        phone: json["phone"] as String,
        email: json["email"] as String?,
        walletBalanceFcfa: (json["walletBalanceFcfa"] as num?)?.toDouble() ?? 0,
        ozelPoints: (json["ozelPoints"] as num?)?.toInt() ?? 0,
      );

  AppUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    double? walletBalanceFcfa,
    int? ozelPoints,
  }) =>
      AppUser(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        walletBalanceFcfa: walletBalanceFcfa ?? this.walletBalanceFcfa,
        ozelPoints: ozelPoints ?? this.ozelPoints,
      );
}
