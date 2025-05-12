class UserModel {
  final String userId;
  final String email;
  final String ndp;
  final String kp;
  final String imageUrl;
  final String statusKahwin;
  final String agama;
  final String jantina;
  final String phone;
  final String nama;
  final String sem;
  final String bangsa;

  // Constructor
  UserModel({
    required this.userId,
    required this.email,
    required this.ndp,
    required this.kp,
    required this.imageUrl,
    required this.statusKahwin,
    required this.agama,
    required this.jantina,
    required this.phone,
    required this.nama,
    required this.sem,
    required this.bangsa,
  });

  // Factory method to create a UserModel from a Map<String, String>
  factory UserModel.fromMap(Map<String, String> map) {
    return UserModel(
      userId: map['user_id'] ?? '', // Default to empty string if null
      email: map['email'] ?? '',
      ndp: map['ndp'] ?? '',
      kp: map['kp'] ?? '',
      imageUrl: map['image_url'] ?? '',
      statusKahwin: map['status_kahwin'] ?? '',
      agama: map['agama'] ?? '',
      jantina: map['jantina'] ?? '',
      phone: map['phone'] ?? '',
      nama: map['nama'] ?? '',
      sem: map['sem'] ?? '',
      bangsa: map['bangsa'] ?? '',
    );
  }

  // Method to convert the UserModel to a Map<String, String> for storage
  Map<String, String> toMap() {
    return {
      'user_id': userId,
      'email': email,
      'ndp': ndp,
      'kp': kp,
      'image_url': imageUrl,
      'status_kahwin': statusKahwin,
      'agama': agama,
      'jantina': jantina,
      'phone': phone,
      'nama': nama,
      'sem': sem,
      'bangsa': bangsa,
    };
  }
}
