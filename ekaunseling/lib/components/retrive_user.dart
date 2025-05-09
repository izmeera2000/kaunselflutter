import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> getUserDetails() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve the saved user info
  String? userId = prefs.getString('user_id');
  String? email = prefs.getString('email');
  String? ndp = prefs.getString('ndp');
  String? kp = prefs.getString('kp');
  String? imageUrl = prefs.getString('image_url');   // New field
  String? statusKahwin = prefs.getString('status_kahwin');  // New field
  String? agama = prefs.getString('agama');  // New field
  String? jantina = prefs.getString('jantina');  // New field
  String? phone = prefs.getString('phone');  // New field
  String? nama = prefs.getString('nama');  // New field
  String? sem = prefs.getString('sem');  // New field
  String? bangsa = prefs.getString('bangsa');  // New field

  // Check if any user details are missing
  if (userId == null || email == null || ndp == null || kp == null || 
      imageUrl == null || statusKahwin == null || agama == null || 
      jantina == null || phone == null || nama == null || sem == null || 
      bangsa == null) {
    // Return a map indicating that some user details are not found
    return {
      'status': 'not_found',  // Status indicating details are not found
    };
  }

  // Return user details if all fields are available
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
