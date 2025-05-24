import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekaunsel/components/user_model.dart';

Future<UserModel> getUserDetails() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    // Retrieve the saved user info with nullable types
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
      'role': prefs.getString('role'),
    };

    // Return user details as UserModel with nullable fields
    return UserModel(
      userId: userDetails['user_id'],   // Nullable
      email: userDetails['email'],      // Nullable
      ndp: userDetails['ndp'],          // Nullable
      kp: userDetails['kp'],            // Nullable
      imageUrl: userDetails['image_url'],  // Nullable
      statusKahwin: userDetails['status_kahwin'], // Nullable
      agama: userDetails['agama'],      // Nullable
      jantina: userDetails['jantina'],  // Nullable
      phone: userDetails['phone'],      // Nullable
      nama: userDetails['nama'],        // Nullable
      sem: userDetails['sem'],          // Nullable
      bangsa: userDetails['bangsa'],    // Nullable
      role: userDetails['role'],    // Nullable
    );
  } catch (e) {
    // Handle errors gracefully
    debugPrint('Error fetching user details: ${e.toString()}');
    throw Exception("Error fetching user details: ${e.toString()}");
  }
}
