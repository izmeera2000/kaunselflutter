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
prefs.setString('email', userDetails['email'] ?? '');
prefs.setString('ndp', userDetails['ndp']?.toString() ?? '');
prefs.setString('kp', userDetails['kp']?.toString() ?? '');
prefs.setString('image_url', userDetails['image_url'] ?? '');
prefs.setString('status_kahwin', userDetails['status_kahwin'] ?? '');
prefs.setString('agama', userDetails['agama'] ?? '');
prefs.setString('jantina', userDetails['jantina']?.toString() ?? '');
prefs.setString('phone', userDetails['phone']?.toString() ?? '');
prefs.setString('nama', userDetails['nama'] ?? '');
prefs.setString('sem', userDetails['sem']?.toString() ?? '');
prefs.setString('bangsa', userDetails['bangsa'] ?? '');
prefs.setString('role', role ?? '');

  // Save login credentials if Remember Me is checked
  if (rememberMe) {
    prefs.setBool('remember_me', true);
  } else {
    prefs.setBool('remember_me', false);
  }
}
Future<void> printSavedUserDetails() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  print('--- Saved User Details ---');
  print('User ID: ${prefs.getString('user_id')}');
  print('Email: ${prefs.getString('email')}');
  print('NDP: ${prefs.getString('ndp')}');
  print('KP: ${prefs.getString('kp')}');
  print('Image URL: ${prefs.getString('image_url')}');
  print('Status Kahwin: ${prefs.getString('status_kahwin')}');
  print('Agama: ${prefs.getString('agama')}');
  print('Jantina: ${prefs.getString('jantina')}');
  print('Phone: ${prefs.getString('phone')}');
  print('Nama: ${prefs.getString('nama')}');
  print('Sem: ${prefs.getString('sem')}');
  print('Bangsa: ${prefs.getString('bangsa')}');
  print('Role: ${prefs.getString('role')}');
  print('Remember Me: ${prefs.getBool('remember_me') ?? false}');
  print('--------------------------');
}
