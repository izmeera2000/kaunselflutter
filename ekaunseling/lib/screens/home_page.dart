import 'package:doctor_appointment_app/components/appointment_card.dart';
import 'package:doctor_appointment_app/components/doctor_card.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:doctor_appointment_app/screens/profile_page.dart';
import 'package:doctor_appointment_app/components/retrive_user.dart'; // Ensure this import is correct
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctor_appointment_app/components/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> medCat = [
    {"icon": FontAwesomeIcons.heartPulse, "category": "Kaunseling"},
  ];

  String userName = 'Loading...'; // Default value for the user name
  String userProfileImageUrl = ' ';

  @override
  void initState() {
    super.initState();
    fetchUserDetails(); // Fetch user details when the page loads
  }

  // Fetch user details from SharedPreferences
  Future<void> fetchUserDetails() async {
  try {
    // Fetch the user details as a UserModel instance
    UserModel user = await getUserDetails();
    
    setState(() {
      // Safely check and update user details
      userName = user.nama.isNotEmpty ? user.nama : 'User'; // Default to 'User' if no name found

      // Safely construct the profile image URL
      String userId = user.userId; // Ensure userId exists
      String imageUrl = user.imageUrl; // Ensure imageUrl exists

      if (userId.isNotEmpty && imageUrl.isNotEmpty) {
        userProfileImageUrl = 'https://kaunselingadtectaiping.com.my/assets/img/user/$userId/$imageUrl';
      } else {
        userProfileImageUrl = ''; // Default image or fallback can be assigned here
      }
    });
  } catch (e) {
    // Handle errors, possibly update UI for error state
    setState(() {
      userName = 'Guest'; // Default to 'Guest' if there's an error
      userProfileImageUrl = ''; // Fallback image URL
    });
    print("Error fetching user details: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Hi, ${userName}", // Display the fetched user name
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "How can i help you today?", // Display the fetched user name
                              style: const TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors
                              .grey, // Optional: default background color
                          child: ClipOval(
                            // Clip the child into a circular shape
                            child: Image.network(
                              userProfileImageUrl,
                              fit: BoxFit.cover,
                              height:
                                  100, // Ensure the size matches the radius
                              width:
                                  100, // Ensure the size matches the radius
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to asset image in case of error
                                return Image.asset(
                                  'assets/jawjoe.jpg',
                                  fit: BoxFit.cover,
                                  height:
                                      100, // Ensure the size matches the radius
                                  width:
                                      100, // Ensure the size matches the radius
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Config.spaceMedium,
                // const Text(
                //   'Category',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                // ),
                // Config.spaceSmall,
                // // Build category list
                // SizedBox(
                //   height: Config.heightSize * 0.05,
                //   child: ListView(
                //     scrollDirection: Axis.horizontal,
                //     children: List<Widget>.generate(medCat.length, (index) {
                //       return Card(
                //         margin: const EdgeInsets.only(right: 20),
                //         color: Config.primaryColor,
                //         child: Padding(
                //           padding: const EdgeInsets.symmetric(
                //             horizontal: 15,
                //             vertical: 10,
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceAround,
                //             children: <Widget>[
                //               FaIcon(
                //                 medCat[index]['icon'],
                //                 color: Colors.white,
                //               ),
                //               const SizedBox(width: 20),
                //               Text(
                //                 medCat[index]['category'],
                //                 style: const TextStyle(
                //                   fontSize: 16,
                //                   color: Colors.white,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       );
                //     }),
                //   ),
                // ),

                Config.spaceSmall,
                const Text(
                  'Appointment Today',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Config.spaceSmall,
                AppointmentCard(),
                Config.spaceSmall,
                Text(
                  'Kaunselor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Config.spaceSmall,
                Column(
                  children: List.generate(1, (index) {
                    return const DoctorCard(route: 'doctor_details');
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
