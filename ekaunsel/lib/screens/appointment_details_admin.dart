import 'dart:convert';
import 'package:ekaunsel/components/retrive_user.dart';
import 'package:ekaunsel/components/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/config.dart'; // Update import as needed

class AppointmentDetailsPage extends StatefulWidget {
  final String id;

  const AppointmentDetailsPage({super.key, required this.id});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  // Time pickers for start and end times
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  TextEditingController _rejectReasonController =
      TextEditingController(); // Controller for rejection reason
  TextEditingController _startTimeController =
      TextEditingController(); // Controller for rejection reason
  TextEditingController _endTimeController =
      TextEditingController(); // Controller for rejection reason

  Future<Map<String, dynamic>?> fetchDetail() async {
    final url = Uri.parse('${Config.base_url}senaraitemujanji');
    final requestBody = {
      'senaraitemujanji_details_flutter': 'test', // Required by your PHP logic
      'senaraitemujanji_details_flutter[id]': widget.id,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.isNotEmpty ? data[0] : null;
    } else {
      throw Exception('Failed to load details');
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = selectedTime;
        } else {
          _endTime = selectedTime;
        }
      });
    }
  }

  Future<void> _showApproveDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Time'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Start Time'),
                    subtitle: Text(_startTime.format(context)),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? selected = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (selected != null) {
                        setState(() => _startTime = selected);
                      }
                    },
                  ),
                  ListTile(
                    title: Text('End Time'),
                    subtitle: Text(_endTime.format(context)),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? selected = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (selected != null) {
                        setState(() => _endTime = selected);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Call function with selected times
                    _approveAppointment();
                    Navigator.pop(context);
                  },
                  child: Text('Approve'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to show rejection reason dialog
  Future<void> _showRejectDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Rejection Reason'),
          content: TextField(
            controller: _rejectReasonController,
            decoration: InputDecoration(hintText: "Enter reason for rejection"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Send reject request to backend here
                _rejectAppointment();
                Navigator.pop(context);
              },
              child: Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  // Reject Appointment (send to backend)
  Future<void> _rejectAppointment() async {
    final UserModel user = await getUserDetails();

    final url = Uri.parse(
        '${Config.base_url}kaunselor_reject_flutter'); // Your backend URL
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'kaunselor_reject_flutter[id]': widget.id,
        'kaunselor_reject_flutter[sebab]': _rejectReasonController.text,
        'kaunselor_reject_flutter[user_id]': user.userId,
      },
    );

    if (response.statusCode == 200) {
      print("Appointment rejected successfully");
    } else {
      print("Failed to reject appointment");
    }
  }

  Future<void> _approveAppointment() async {
    final url = Uri.parse('${Config.base_url}kaunselor_approve_flutter');
    final mula = _startTime.format(context); // e.g., 10:30 AM
    final tamat = _endTime.format(context); // e.g., 11:30 AM
    final UserModel user = await getUserDetails();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'kaunselor_approve_flutter[id]': widget.id,
          'kaunselor_approve_flutter[mula]': mula,
          'kaunselor_approve_flutter[tamat]': tamat,
          'kaunselor_approve_flutter[user_id]': user.userId,
        },
      );

      if (response.statusCode == 200) {
        print("✅ Appointment approved successfully");
        // Optionally show a dialog/snackbar:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment approved.')),
        );
        Navigator.pop(context); // Close the screen/dialog
      } else {
        print(
            "❌ Failed to approve appointment. Status: ${response.statusCode}");
        print("Response body: ${response.body}");
        _showErrorDialog("Failed to approve appointment.");
      }
    } catch (e) {
      print("❌ Error: $e");
      _showErrorDialog("Something went wrong. Please try again.");
    }
  }

  Future<void> startAppointment() async {
    final url = Uri.parse('${Config.base_url}temujanji_update_flutter');
    final UserModel user = await getUserDetails();

    final response = await http.post(url, body: {
      'temujanji_update_flutter[meeting_id]': widget.id,
      'temujanji_update_flutter[start]': TimeOfDay.now(),
      'temujanji_update_flutter[user_id]': user.userId,
    });

    if (response.statusCode == 200) {
      print('Appointment started successfully');
    } else {
      print('Failed to start appointment: ${response.body}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appointment Details")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            // Fetching appointment details
            future: fetchDetail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text("No data found."));
              }

              final details = snapshot.data!;
              int status = int.tryParse(details['status'] ?? '0') ?? 0;

              bool isStatusZero = status == 0; // Pending / Not processed
              bool isStatusOne = status == 1; // Awaiting Approval
              bool isStatusTwo = status == 2; // Approved or Rejected
              bool isStatusThree = status == 3; // Approved or Rejected
              bool isStatusFour = status == 4; // Approved or Rejected
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius:
                              40, // Optional: Set a custom radius for the avatar
                          backgroundImage: NetworkImage(
                              "${Config.base_url}/assets/img/user/${details['user_id']}/${details['image_url']!}"), // Load image from URL
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${details['nama']}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${details['ndp']}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Visit Time',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('${details['tarikh']} '),
                        if (isStatusTwo) ...[
                          SizedBox(height: 8),
                          Text(
                              '${details['masa_mula']}- ${details['masa_tamat']}'),
                        ]
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Details',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Masalah : ${details['masalah']}'),
                        Text('Status : ${details['status']}'),
                      ],
                    ),
                    SizedBox(height: 16),

                    // If the status is 1, show the buttons
                    if (isStatusOne) ...[
                      const SizedBox(
                          height: 20), // Add space between text and buttons

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _showApproveDialog, // Approve Appointment
                        child: Text("Approve"),
                      ),
                      ElevatedButton(
                        onPressed: _showRejectDialog, // Reject Appointment
                        child: Text("Reject"),
                      ),
                    ],
                    if (isStatusTwo) ...[
                      const SizedBox(
                          height: 20), // Add space between text and buttons

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: startAppointment, // Approve Appointment
                        child: Text("Start"),
                      ),
                    ]
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
