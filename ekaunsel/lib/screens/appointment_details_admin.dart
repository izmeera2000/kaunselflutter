import 'dart:convert';
import 'package:ekaunsel/components/retrive_user.dart';
import 'package:ekaunsel/components/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/config.dart'; // Update import as needed
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

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
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Call function with selected times
                    await _approveAppointment();
                    if (!context.mounted) return;

                    Navigator.pop(context);
                    if (!mounted) return;
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
      debugPrint("Appointment rejected successfully");
    } else {
      debugPrint("Failed to reject appointment");
    }
     Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => AppointmentDetailsPage(id: widget.id)),
    );
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
        debugPrint("✅ Appointment approved successfully");
        // Optionally show a dialog/snackbar:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment approved.')),
        );
        if (!mounted) return;
        Navigator.pop(context); // Close the screen/dialog
      } else {
        debugPrint(
            "❌ Failed to approve appointment. Status: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
        _showErrorDialog("Failed to approve appointment.");
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      _showErrorDialog("Something went wrong. Please try again.");
    }

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => AppointmentDetailsPage(id: widget.id)),
    );
  }

  Future<void> startAppointment() async {
    final url = Uri.parse('${Config.base_url}temujanji_update_flutter');
    final UserModel user = await getUserDetails();
    TimeOfDay time = TimeOfDay(hour: 14, minute: 30);
    String formattedTime = '${time.hour}:${time.minute}';
    final response = await http.post(url, body: {
      'temujanji_update_flutter[meeting_id]': widget.id,
      'temujanji_update_flutter[start]': formattedTime,
      'temujanji_update_flutter[user_id]': user.userId,
    });

    if (response.statusCode == 200) {
      debugPrint('Appointment started successfully');
    } else {
      debugPrint('Failed to start appointment: ${response.body}');
    }
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => AppointmentDetailsPage(id: widget.id)),
    );
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
              builder: (_) => AppointmentDetailsPage(id: widget.id)),
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
                  AppointmentDetailsPage(id: newMeetingId.toString()),
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
                        Text('Status : ${details['status']}'),
                      ],
                    ),
                    SizedBox(height: 16),

                    // If the status is 1, show the buttons
                    if (isStatusOne) ...[
                      const SizedBox(height: 20), // space above buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // center buttons horizontally
                        children: [
                          ElevatedButton(
                            onPressed: _showApproveDialog,
                            child: const Text("Approve"),
                          ),
                          const SizedBox(width: 16), // space between buttons
                          ElevatedButton(
                            onPressed: _showRejectDialog,
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
                    ],

                    if (isStatusTwo) ...[
                      const SizedBox(
                          height: 20), // Add space between text and buttons

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          debugPrint("start startAppointment");
                          await startAppointment();
                        }, // Approve Appointment
                        child: Text("Start"),
                      ),
                    ],
                    if (isStatusThree) ...[
                      const SizedBox(
                          height: 20), // Add space between text and buttons

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          endAppointment(widget.id); // Pass actual meeting ID

                          // Optionally re-render or refresh current screen
                        },
                        child: Text("End"),
                      ),
                    ],
                    if (isStatusFour) ...[
                      const SizedBox(
                          height: 20), // Add space between text and buttons

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // await endAppointment(widget.id); // Pass actual meeting ID
                          showFinalizeDialog(
                            context,
                            meetingId: widget.id,
                            userId: details['user_id'],
                          );
                          // Optionally re-render or refresh current screen
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                                builder: (_) =>
                                    AppointmentDetailsPage(id: widget.id)),
                          );
                        },
                        child: Text("Repeat"),
                      ),
                    ],
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
