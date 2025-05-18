import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctor_appointment_app/components/user_model.dart';

Future<UserModel> getUserDetails() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    // Retrieve the saved user info
    Map<String, String?> userDetails = {
      'user_id': prefs.getString('user_id'),
      'email': prefs.getString('email'),
      'ndp': prefs.getString('ndp'),
      'kp': prefs.getString('kp'),
      'image_url': prefs.getString('image_url'),
      'status_kahwin': prefs.getString('status_kahwin'),
      'agama': prefs.getString('agama'),
      'jantina': prefs.getString('jantina'),
      'phone': prefs.getString('phone'),
      'nama': prefs.getString('nama'),
      'sem': prefs.getString('sem'),
      'bangsa': prefs.getString('bangsa'),
    };

    // Check if any user details are missing
    if (userDetails.values.any((detail) => detail == null)) {
      throw Exception("Some user details are missing.");
    }

    // Return user details as UserModel
    return UserModel(
      userId: userDetails['user_id']!,
      email: userDetails['email']!,
      ndp: userDetails['ndp']!,
      kp: userDetails['kp']!,
      imageUrl: userDetails['image_url']!,
      statusKahwin: userDetails['status_kahwin']!,
      agama: userDetails['agama']!,
      jantina: userDetails['jantina']!,
      phone: userDetails['phone']!,
      nama: userDetails['nama']!,
      sem: userDetails['sem']!,
      bangsa: userDetails['bangsa']!,
    );
  } catch (e) {
    // Handle errors gracefully
    print('Error fetching user details: ${e.toString()}');
    throw Exception("Error fetching user details: ${e.toString()}");
  }
}
