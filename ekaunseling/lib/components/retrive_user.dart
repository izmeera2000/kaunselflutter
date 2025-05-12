import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctor_appointment_app/components/user_model.dart';

Future<UserModel> getUserDetails() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    // Retrieve the saved user info
    String? userId = prefs.getString('user_id');
    String? email = prefs.getString('email');
    String? ndp = prefs.getString('ndp');
    String? kp = prefs.getString('kp');
    String? imageUrl = prefs.getString('image_url');
    String? statusKahwin = prefs.getString('status_kahwin');
    String? agama = prefs.getString('agama');
    String? jantina = prefs.getString('jantina');
    String? phone = prefs.getString('phone');
    String? nama = prefs.getString('nama');
    String? sem = prefs.getString('sem');
    String? bangsa = prefs.getString('bangsa');

    // Check if any user details are missing and return a status map indicating so
    if (userId == null || email == null || ndp == null || kp == null ||
        imageUrl == null || statusKahwin == null || agama == null ||
        jantina == null || phone == null || nama == null || sem == null || 
        bangsa == null) {
      throw Exception("User details are missing.");
    }

    // Return user details as UserModel
    return UserModel(
      userId: userId,
      email: email,
      ndp: ndp,
      kp: kp,
      imageUrl: imageUrl,
      statusKahwin: statusKahwin,
      agama: agama,
      jantina: jantina,
      phone: phone,
      nama: nama,
      sem: sem,
      bangsa: bangsa,
    );
  } catch (e) {
    // Catch any potential exceptions and handle them
    throw Exception("Error fetching user details: ${e.toString()}");
  }
}
