import 'dart:convert';

import 'package:ekaunsel/components/appointment_card.dart';
import 'package:ekaunsel/components/doctor_card.dart';
import 'package:ekaunsel/components/notification.dart';
import 'package:ekaunsel/screens/appointment_details_admin.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekaunsel/screens/profile_page.dart';
import 'package:ekaunsel/components/retrive_user.dart'; // Ensure this import is correct
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekaunsel/components/user_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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
  List<dynamic> todaysAppointments = [];
  bool isLoadingToday = true;
  @override
  void initState() {
    super.initState();
    fetchUserDetails().then((_) => fetchTodaysAppointments());
    FirebaseMessaging.instance.subscribeToTopic('semangat');
  }

  // Fetch user details from SharedPreferences
  Future<void> fetchUserDetails() async {
    try {
      // Fetch the user details as a UserModel instance
      UserModel user = await getUserDetails();

      setState(() {
        // Safely check and update user details
        userName = user.nama!.isNotEmpty
            ? user.nama!
            : 'User'; // Default to 'User' if no name found

        // Safely construct the profile image URL
        String userId = user.userId!; // Ensure userId exists
        String imageUrl = user.imageUrl!; // Ensure imageUrl exists

        if (userId.isNotEmpty && imageUrl.isNotEmpty) {
          userProfileImageUrl =
              '${Config.base_url}assets/img/user/$userId/$imageUrl';
        } else {
          userProfileImageUrl =
              ''; // Default image or fallback can be assigned here
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




  Future<List<dynamic>> fetchAppointmentsToday(
      String userId, String role) async {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final url = Uri.parse('${Config.base_url}senaraitemujanji');

    final requestBody = {
      'senaraitemujanji_flutter': "test",
      'senaraitemujanji_flutter[start]': formattedDate,
      'senaraitemujanji_flutter[end]': formattedDate,
      'senaraitemujanji_flutter[user_id]': userId,
      'senaraitemujanji_flutter[status2]': 'upcoming',
      'senaraitemujanji_flutter[limit]': '10',
      'senaraitemujanji_flutter[offset]': '0',
      'senaraitemujanji_flutter[role]': role,
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requestBody,
    );
    print(requestBody);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // print(data);
      print("Appointments API data: $data");

      return data;
    } else {
      throw Exception('Failed to load today\'s appointments');
    }
  }

  Future<void> fetchTodaysAppointments() async {
    setState(() {
      isLoadingToday = true;
    });

    try {
      final UserModel user = await getUserDetails();
      final data = await fetchAppointmentsToday(user.userId!, user.role!);

      // Filter only status == 2 (Confirmed)
      final filteredAppointments = data.where((appointment) {
        return appointment['status'].toString() == '2';
      }).toList();

      setState(() {
        todaysAppointments = filteredAppointments;
        isLoadingToday = false;
      });
    } catch (e) {
      print('Error fetching today\'s appointments: $e');
      setState(() {
        isLoadingToday = false;
      });
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
                // Appointment list or loader
                if (todaysAppointments.isEmpty)
                  Text('No appointments today.')
                else
                  Column(
                    children: todaysAppointments.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var appointment = entry.value;
                      bool isLastElement = idx == todaysAppointments.length - 1;

                      // Build the profile image URL
                      String profileImageUrl = '';
                      if (appointment['user_id'] != null &&
                          appointment['image_url'] != null) {
                        profileImageUrl =
                            '${Config.base_url}assets/img/user/${appointment['user_id']}/${appointment['image_url']}';
                      }

                      return GestureDetector(
                        onTap: () {
                          final String scheduleId = appointment['id']
                              .toString(); // ensure it's a String
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => AppointmentDetailsPage(
                          //         id: scheduleId), // Ensure `id` is passed here
                          //   ),
                          // );
                        },
                        child: Card(
                          margin: !isLastElement
                              ? const EdgeInsets.only(bottom: 10)
                              : EdgeInsets.zero,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey[200],
                                          backgroundImage: profileImageUrl
                                                  .isNotEmpty
                                              ? NetworkImage(profileImageUrl)
                                              : AssetImage(
                                                      'assets/default_profile.png')
                                                  as ImageProvider,
                                          radius: 25,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                appointment['nama'] ??
                                                    'No Name',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                appointment['masalah'] ??
                                                    'No problem description',
                                                style: const TextStyle(
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Date and time
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 5),
                                        Text(
                                          appointment['tarikh'] ?? 'No Date',
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                        const SizedBox(width: 20),
                                        Icon(Icons.access_time,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 5),
                                        Text(
                                          appointment['masa_mula'] != null
                                              ? appointment['masa_mula']
                                                  .toString()
                                                  .substring(11, 16) // HH:mm
                                              : 'No Time',
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Status
                                    Text(
                                      'Status: ${_mapStatus(appointment['status'])}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                Config.spaceSmall,
                Text(
                  'Kaunselor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Config.spaceSmall,
                ElevatedButton(
                    onPressed: () async {
                      await sendNotificationTopic("katasemangat", "kata-kata hari ini", "dh makan ke belum");
                    },
                    child: Text("adsada")),
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

String _mapStatus(dynamic status) {
  switch (status?.toString()) {
    case '1':
      return 'Pending';
    case '2':
      return 'Confirmed';
    case '3':
      return 'Ongoing';
    case '4':
      return 'Ended';
    default:
      return 'Rejected';
  }
}
