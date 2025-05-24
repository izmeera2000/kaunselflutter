import 'dart:convert';

import 'package:ekaunsel/components/appointment_card.dart';
import 'package:ekaunsel/components/doctor_card.dart';
import 'package:ekaunsel/components/notification.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekaunsel/components/retrive_user.dart'; // Ensure this import is correct
import 'package:ekaunsel/components/user_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

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
      debugPrint("Error fetching user details: $e");
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

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // debugPrint(data);
      debugPrint("Appointments API data: $data");

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
      debugPrint('Error fetching today\'s appointments: $e');
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
                              "Hi, $userName", // Display the fetched user name
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
                  Container(
                    height:
                        250, // Adjust height as needed for your ScheduleCard
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: todaysAppointments.map((appointment) {
                          // Build the profile image URL
                          String profileImageUrl = '';
                          if (appointment['user_id'] != null &&
                              appointment['image_url'] != null) {
                            profileImageUrl =
                                '${Config.base_url}assets/img/user/${appointment['user_id']}/${appointment['image_url']}';
                          }

                          String name = appointment['nama'] ?? 'No Name';
                          String category =
                              appointment['masalah'] ?? 'No category';
                          String date = appointment['tarikh'] ?? 'No Date';
                          String time = appointment['masa_mula'] != null
                              ? appointment['masa_mula']
                                  .toString()
                                  .substring(11, 16)
                              : '';
                          String status = _mapStatus(appointment['status']);

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ScheduleCard(
                              imageUrl: profileImageUrl,
                              name: name,
                              category: category,
                              title: category,
                              date: date,
                              time: time,
                              status: status,
                              onTap: () {
                                final String scheduleId =
                                    appointment['id'].toString();
                                // Navigator.push(
                                //   context,
                                //   CupertinoPageRoute(
                                //     builder: (context) =>
                                //         AppointmentDetailsPage(id: scheduleId),
                                //   ),
                                // );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                Config.spaceSmall,
                Text(
                  'Kaunselor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Config.spaceSmall,
            
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
