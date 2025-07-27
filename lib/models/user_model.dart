class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final String schoolName;
  final String codeEcole;
  final String niveauEcole;
  final String gender;
  final String role;
  final String photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.schoolName,
    required this.codeEcole,
    required this.niveauEcole,
    required this.gender,
    required this.role,
    required this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      schoolName: data['schoolName'] ?? '',
      codeEcole: data['codeEcole'] ?? '',
      niveauEcole: data['niveauEcole'] ?? '',
      gender: data['gender'] ?? '',
      role: data['role'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'schoolName': schoolName,
      'codeEcole': codeEcole,
      'niveauEcole': niveauEcole,
      'gender': gender,
      'role': role,
      'photoUrl': photoUrl,
    };
  }
}
