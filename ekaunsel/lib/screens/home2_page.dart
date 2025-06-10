import 'dart:convert';

import 'package:ekaunsel/components/appointment_card.dart';
import 'package:ekaunsel/components/notification.dart';
import 'package:ekaunsel/screens/appointment_details_admin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:ekaunsel/components/user_model.dart';
import 'package:ekaunsel/components/retrive_user.dart'; // For getUserDetails()
import 'package:ekaunsel/utils/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home2Page extends StatefulWidget {
  const Home2Page({super.key});

  @override
  State<Home2Page> createState() => _Home2PageState();
}

class _Home2PageState extends State<Home2Page> {
  List<dynamic> todaysAppointments = [];
  bool isLoadingToday = true;
  String userInput = '';

  String userName = 'Loading...';
  String userProfileImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserDetails().then((_) => fetchTodaysAppointments());
    checkLoginStatus(context);
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("check");
    String? userId = prefs.getString('user_id');
    String? userRole = prefs.getString('role');
    print(userId);
    print(userRole);

    if (userId != null && userRole != null) {
      // User is logged in, navigate to the appropriate page based on their role
      if (userRole == '1') {
        print("admin");
      } else {
        print("user");
      }
    } else {
      // User is not logged in, stay on the login page
    }
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
    debugPrint(formattedDate);

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
      debugPrint('Error fetching today\'s appointments: $e');
      setState(() {
        isLoadingToday = false;
      });
    }
  }

  Future<void> _showInputDialog() async {
    String tempInput = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Your Wisdom'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Type something wise...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            tempInput = value;
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Submit'),
            onPressed: () async {
              await sendNotificationTopic(
                  "katasemangat", "kata-kata hari ini", tempInput, "site1");

              Navigator.pop(context, tempInput);
            },
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        userInput = result;
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 10),

                // Appointment list or loader
                if (todaysAppointments.isEmpty)
                  Text('No appointments today.')
                else
                  Container(
                    height: 250, // height to comfortably fit your ScheduleCard
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: todaysAppointments.map((appointment) {
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
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        AppointmentDetailsPage(id: scheduleId),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                Config.spaceSmall,
                Text(
                  'Words Of Wisdom',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showInputDialog,
                  icon: const Icon(Icons.edit,
                      color: Colors.white), // 👈 icon color
                  label: const Text(
                    'Add Wisdom',
                    style: TextStyle(color: Colors.white), // 👈 text color
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor:
                        Colors.white, // 👈 ensures icon/text are white
                  ),
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
