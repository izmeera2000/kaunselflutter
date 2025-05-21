import 'dart:convert';

import 'package:ekaunsel/components/appointment_card.dart';
import 'package:ekaunsel/screens/appointment_details_admin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:ekaunsel/components/user_model.dart';
import 'package:ekaunsel/components/retrive_user.dart'; // For getUserDetails()
import 'package:ekaunsel/utils/config.dart';

class Home2Page extends StatefulWidget {
  const Home2Page({super.key});

  @override
  State<Home2Page> createState() => _Home2PageState();
}

class _Home2PageState extends State<Home2Page> {
  List<dynamic> todaysAppointments = [];
  bool isLoadingToday = true;

  String userName = 'Loading...';
  String userProfileImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserDetails().then((_) => fetchTodaysAppointments());
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

  Future<List<dynamic>> fetchAppointmentsToday(String userId) async {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final url = Uri.parse('${Config.base_url}senaraitemujanji');

    final requestBody = {
      'senaraitemujanji_admin_flutter': "test",
      'senaraitemujanji_admin_flutter[start]': formattedDate,
      'senaraitemujanji_admin_flutter[end]': formattedDate,
      'senaraitemujanji_admin_flutter[user_id]': userId,
      'senaraitemujanji_admin_flutter[status2]': 'upcoming',
      'senaraitemujanji_admin_flutter[limit]': '10',
      'senaraitemujanji_admin_flutter[offset]': '0',
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requestBody,
    );

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
      final data = await fetchAppointmentsToday(user.userId!);

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hi, $userName',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Colors.grey, // Optional: default background color
                          child: ClipOval(
                            // Clip the child into a circular shape
                            child: userProfileImageUrl.isNotEmpty
                                ? Image.network(
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
                                        height: 100,
                                        width: 100,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/jawjoe.jpg',
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Appointment Today Title
                Text(
                  'Appointment Today',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentDetailsPage(
                                  id: scheduleId), // Ensure `id` is passed here
                            ),
                          );
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
                                          backgroundImage: (profileImageUrl
                                                      ?.isNotEmpty ??
                                                  false)
                                              ? NetworkImage(profileImageUrl)
                                              : const AssetImage(
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
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                appointment['masalah'] ??
                                                    'No category',
                                                style: const TextStyle(
                                                    color: Colors.black54),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
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
                  )
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
