import 'dart:convert';
import 'package:ekaunsel/components/retrive_user.dart';
import 'package:ekaunsel/components/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/config.dart'; // Update import as needed
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class AppointmentDetailsPage2 extends StatefulWidget {
  final String id;

  const AppointmentDetailsPage2({super.key, required this.id});

  @override
  State<AppointmentDetailsPage2> createState() =>
      _AppointmentDetailsPage2State();
}

class _AppointmentDetailsPage2State extends State<AppointmentDetailsPage2> {
  // Time pickers for start and end times
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  final TextEditingController _rejectReasonController =
      TextEditingController(); // Controller for rejection reason
// Controller for rejection reason
// Controller for rejection reason

  Future<Map<String, dynamic>?> fetchDetail() async {
    final url = Uri.parse('${Config.base_url}senaraitemujanji');

    print("id is ${widget.id}");
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

  // Function to show rejection reason dialog

  Future<void> endAppointment(String meetingId) async {
    final url = Uri.parse('${Config.base_url}temujanji_end_flutter');

    try {
      final response = await http.post(
        url,
        body: {
          'temujanji_end_flutter': '1', // Needed for `isset()` to work
          'temujanji_end_flutter[meeting_id]': meetingId,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Appointment ended successfully');
        // Optionally, refresh the page or show confirmation
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (_) => AppointmentDetailsPage2(id: widget.id)),
        );
      } else {
        debugPrint('Failed to end appointment: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error ending appointment: $e');
    }
  }

  Future<void> showFinalizeDialog(
    BuildContext context, {
    required String meetingId,
    required String userId,
  }) async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    DateTime? selectedDate;
    TextEditingController masalahController = TextEditingController();

    final user = await getUserDetails(); // fetch kaunselor info
    final String? kaunselorId = user.userId; // get the kaunselor_id

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Finalize Appointment"),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(selectedDate == null
                      ? 'Select Date'
                      : 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 1)),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() => selectedDate = pickedDate);
                    }
                  },
                ),
                ListTile(
                  title: Text(startTime == null
                      ? 'Select Start Time'
                      : 'Start: ${startTime?.format(context)}'),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => startTime = picked);
                    }
                  },
                ),
                ListTile(
                  title: Text(endTime == null
                      ? 'Select End Time'
                      : 'End: ${endTime?.format(context)}'),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => endTime = picked);
                    }
                  },
                ),
                TextField(
                  controller: masalahController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Enter your issue',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedDate != null &&
                  startTime != null &&
                  endTime != null &&
                  masalahController.text.trim().isNotEmpty) {
                final timeFormatter = DateFormat('HH:mm');
                final dateFormatter = DateFormat('yyyy-MM-dd');

                final String formattedStart = timeFormatter.format(
                  DateTime(0, 0, 0, startTime!.hour, startTime!.minute),
                );
                final String formattedEnd = timeFormatter.format(
                  DateTime(0, 0, 0, endTime!.hour, endTime!.minute),
                );
                final String formattedDate =
                    dateFormatter.format(selectedDate!);

                finalizeFlutterAppointment(
                  meetingId: meetingId,
                  userId: userId,
                  kaunselorId: kaunselorId,
                  time1: formattedStart,
                  time2: formattedEnd,
                  tarikh1: formattedDate,
                  masalah1: masalahController.text.trim(),
                );

                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please fill all fields")),
                );
              }
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> finalizeFlutterAppointment({
    required String meetingId,
    required String userId,
    required String? kaunselorId,
    required String time1,
    required String time2,
    required String tarikh1,
    required String masalah1,
  }) async {
    final url = Uri.parse('${Config.base_url}temujanji_final_flutter');

    try {
      final response = await http.post(
        url,
        body: {
          'temujanji_final_flutter': '1',
          'meeting_id': meetingId,
          'user_id': userId,
          'kaunselor_id': kaunselorId,
          'time1': time1,
          'time2': time2,
          'tarikh1': tarikh1,
          'masalah1': masalah1,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          final newMeetingId = jsonResponse['meeting_id'];

          debugPrint(
              "Appointment finalized with new meeting ID: $newMeetingId");

          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (_) =>
                  AppointmentDetailsPage2(id: newMeetingId.toString()),
            ),
          );
        } else {
          debugPrint("Error from server: ${jsonResponse['message']}");
        }
      } else {
        debugPrint("Failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment Details"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
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

// Pending / Not processed
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
                        Expanded(
                          child: Column(
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
                        Text('Date : ${details['tarikh']} '),
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
Text('Status: ${_getStatusLabel(details['status'])}'),
                      ],
                    ),
                    SizedBox(height: 16),
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
String _getStatusLabel(dynamic status) {
  switch (status) {
    case 1:
      return 'Pending';
    case 2:
      return 'Confirmed';
    case 3:
      return 'Started';
    case 4:
      return 'Completed';
    default:
      return 'Unknown';
  }
}
