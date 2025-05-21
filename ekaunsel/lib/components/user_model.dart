class UserModel {
  final String? userId;
  final String? email;
  final String? ndp; // Nullable
  final String? kp; // Nullable
  final String? imageUrl; // Nullable
  final String? statusKahwin; // Nullable
  final String? agama; // Nullable
  final String? jantina; // Nullable
  final String? phone; // Nullable
  final String? nama; // Nullable
  final String? sem; // Nullable
  final String? bangsa; // Nullable
  final String? role; // Nullable

  // Constructor
  UserModel({
    required this.userId,  // Required field
    required this.email,   // Required field
    this.ndp,  // Nullable
    this.kp,   // Nullable
    this.imageUrl, // Nullable
    this.statusKahwin,  // Nullable
    this.agama,  // Nullable
    this.jantina,  // Nullable
    this.phone,  // Nullable
    this.nama,   // Nullable
    this.sem,    // Nullable
    this.bangsa, 
    this.role, 
  });

  // Factory method to create a UserModel from a Map<String, String>
  factory UserModel.fromMap(Map<String, String> map) {
    return UserModel(
      userId: map['user_id'] ?? '',  // Default to empty string if null
      email: map['email'] ?? '',     // Default to empty string if null
      ndp: map['ndp'],               // Nullable
      kp: map['kp'],                 // Nullable
      imageUrl: map['image_url'],    // Nullable
      statusKahwin: map['status_kahwin'], // Nullable
      agama: map['agama'],           // Nullable
      jantina: map['jantina'],       // Nullable
      phone: map['phone'],           // Nullable
      nama: map['nama'],             // Nullable
      sem: map['sem'],               // Nullable
      bangsa: map['bangsa'],         // Nullable
      role: map['role'],         // Nullable
    );
  }

  // Method to convert the UserModel to a Map<String, String> for storage
  Map<String, String> toMap() {
    return {
      'user_id': userId  ?? '',
      'email': email  ?? '',
      'ndp': ndp ?? '',  // Default to empty string if null
      'kp': kp ?? '',    // Default to empty string if null
      'image_url': imageUrl ?? '',  // Default to empty string if null
      'status_kahwin': statusKahwin ?? '',  // Default to empty string if null
      'agama': agama ?? '',  // Default to empty string if null
      'jantina': jantina ?? '',  // Default to empty string if null
      'phone': phone ?? '',  // Default to empty string if null
      'nama': nama ?? '',    // Default to empty string if null
      'sem': sem ?? '',      // Default to empty string if null
      'bangsa': bangsa ?? '', // Default to empty string if null
      'role': role ?? '', // Default to empty string if null
    };
  }
}
