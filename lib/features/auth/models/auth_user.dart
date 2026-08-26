/// A GoLazy account, as returned by the backend's register/login endpoints.
///
/// The backend (Go-Lazy/backend) does not issue any session token today —
/// login/register simply return this user row. It is persisted locally as
/// the signal that the app is "logged in".
class AuthUser {
  const AuthUser({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    required this.renterEnabled,
    required this.ownerEnabled,
    this.renterVerificationStatus,
    this.ownerVerificationStatus,
  });

  final String id;
  final String phone;
  final String? name;
  final String? email;
  final bool renterEnabled;
  final bool ownerEnabled;
  final String? renterVerificationStatus;
  final String? ownerVerificationStatus;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        phone: json['phone'] as String,
        name: json['name'] as String?,
        email: json['email'] as String?,
        renterEnabled: json['renterEnabled'] as bool? ?? true,
        ownerEnabled: json['ownerEnabled'] as bool? ?? false,
        renterVerificationStatus: json['renterVerificationStatus'] as String?,
        ownerVerificationStatus: json['ownerVerificationStatus'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'email': email,
        'renterEnabled': renterEnabled,
        'ownerEnabled': ownerEnabled,
        'renterVerificationStatus': renterVerificationStatus,
        'ownerVerificationStatus': ownerVerificationStatus,
      };
}
