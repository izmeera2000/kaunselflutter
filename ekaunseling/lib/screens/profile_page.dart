import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/screens/login_page.dart';
import 'package:doctor_appointment_app/components/retrive_user.dart'; // Ensure this import is correct
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/components/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Loading...'; // Default value for the user name
  String userProfileImageUrl = ' ';
  String userEmail = ' ';

  @override
  void initState() {
    super.initState();
    fetchUserDetails(); // Fetch user details when the page loads
  }

  Future<void> fetchUserDetails() async {
    try {
      // Fetch user details as a UserModel
      UserModel user = await getUserDetails();

      setState(() {
        // Safely check and update user details
        userName = user.nama.isNotEmpty
            ? user.nama
            : 'User'; // Default to 'User' if no name found
        userEmail = user.email.isNotEmpty
            ? user.email
            : 'User'; // Default to 'User' if no email found

        // Safely construct the profile image URL
        String userId = user.userId; // Ensure user_id exists
        String imageUrl = user.imageUrl; // Ensure image_url exists

        if (userId.isNotEmpty && imageUrl.isNotEmpty) {
          userProfileImageUrl =
              '${Config.base_url}/assets/img/user/$userId/$imageUrl';
        } else {
          userProfileImageUrl = ''; // Fallback image URL or empty
        }
      });
    } catch (e) {
      // Handle errors and update UI to default state (e.g., 'Guest')
      setState(() {
        userName = 'Guest'; // Default to 'Guest' if no user details are found
        userProfileImageUrl = ''; // Fallback image URL or empty
      });
      print("Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Profile Page'),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor:
                    Colors.grey, // Optional: default background color
                child: ClipOval(
                  // Clip the child into a circular shape
                  child: Image.network(
                    userProfileImageUrl,
                    fit: BoxFit.cover,
                    height: 100, // Ensure the size matches the radius
                    width: 100, // Ensure the size matches the radius
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to asset image in case of error
                      return Image.asset(
                        'assets/jawjoe.jpg',
                        fit: BoxFit.cover,
                        height: 100, // Ensure the size matches the radius
                        width: 100, // Ensure the size matches the radius
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  // Navigate to edit profile page
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                onTap: () {
                  // Navigate to change password page
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // clear saved session/token/etc.
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) =>
                        false, // Remove all previous routes
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
