class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? nip;
  final String? unitKerja;
  final String? jabatan;
  final String? phone;
  final String? avatarUrl;
  final String? role;
  final bool? isActive;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.nip,
    this.unitKerja,
    this.jabatan,
    this.phone,
    this.avatarUrl,
    this.role,
    this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      nip: json['nip'] as String?,
      unitKerja: json['unit_kerja'] as String?,
      jabatan: json['jabatan'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : (json['is_active'] == 1 || json['is_active'] == '1'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'nip': nip,
      'unit_kerja': unitKerja,
      'jabatan': jabatan,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'is_active': isActive,
    };
  }
}

