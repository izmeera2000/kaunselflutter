import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserDetails(
  Map<String, dynamic> userDetails,
  String email,
  String? role,
  bool rememberMe,
) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
print('Saving role: ${role ?? 'null value'}');

  // Save user info in SharedPreferences for future use

  prefs.setString('user_id', userDetails['id'].toString());
  prefs.setString('email', userDetails['email']);
  prefs.setString('ndp', userDetails['ndp']);
  prefs.setString('kp', userDetails['kp']);
  prefs.setString('image_url', userDetails['image_url'] ?? '');
  prefs.setString('status_kahwin', userDetails['status_kahwin'] ?? '');
  prefs.setString('agama', userDetails['agama'] ?? '');
  prefs.setString('jantina', userDetails['jantina'] ?? '');
  prefs.setString('phone', userDetails['phone'] ?? '');
  prefs.setString('nama', userDetails['nama'] ?? '');
  prefs.setString('sem', userDetails['sem'] ?? '');
  prefs.setString('bangsa', userDetails['bangsa'] ?? '');
  prefs.setString('role', role ?? '');

  // Save login credentials if Remember Me is checked
  if (rememberMe) {
    prefs.setBool('remember_me', true);
  } else {
    prefs.setBool('remember_me', false);
  }
}
