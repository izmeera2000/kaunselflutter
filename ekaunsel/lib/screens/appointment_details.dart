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
                        Text('Status: ${_getStatusLabel(status)}'),
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
