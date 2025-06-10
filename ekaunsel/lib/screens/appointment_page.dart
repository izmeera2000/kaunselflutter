import 'dart:async';
import 'dart:convert';

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:ekaunsel/screens/appointment_details.dart';
import 'package:ekaunsel/screens/appointment_details_admin.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ekaunsel/components/appointment_card.dart';
import 'package:ekaunsel/components/retrive_user.dart';
import 'package:ekaunsel/components/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

enum FilterStatus { upcoming, completed, cancelled }

class _AppointmentPageState extends State<AppointmentPage> {
  FilterStatus status = FilterStatus.upcoming; //initial status
  Alignment _alignment = Alignment.centerLeft;
  DateTime _selectedDate = DateTime.now();

  List<dynamic> schedules = [];
  bool isLoading = true;
  int currentYear = DateTime.now().year;
  Timer? _yearCheckTimer;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchAndSetSchedules(year: currentYear);

    _yearCheckTimer = Timer.periodic(Duration(hours: 1), (timer) {
      int newYear = DateTime.now().year;
      if (newYear != currentYear) {
        currentYear = newYear;
        fetchAndSetSchedules(year: currentYear);
      }
    });
  }



   @override
  void dispose() {
    _yearCheckTimer?.cancel();
    super.dispose();
  }

  Future<List<dynamic>> fetchAppointments({
    required DateTime start,
    required DateTime end,
    required String status2,
    required int limit,
    required int offset,
    required String user_id, // Add this to accept user_id
    required String role, // Add this to accept user_id
  }) async {
    final url = Uri.parse('${Config.base_url}senaraitemujanji');

    String formattedStart = DateFormat('yyyy-MM-dd').format(start);
    String formattedEnd = DateFormat('yyyy-MM-dd').format(end);

    final requestBody = {
      'senaraitemujanji_flutter': "test",
      'senaraitemujanji_flutter[start]': formattedStart,
      'senaraitemujanji_flutter[end]': formattedEnd,
      'senaraitemujanji_flutter[user_id]': user_id, // Send user_id here
      'senaraitemujanji_flutter[status2]': status2, // Send status2
      'senaraitemujanji_flutter[role]': role, // Send status2
      'senaraitemujanji_flutter[limit]': limit.toString(),
      'senaraitemujanji_flutter[offset]': offset.toString(),
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: requestBody,
    );
    debugPrint('Request Body: $requestBody');

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        debugPrint('Decoded JSON: $data');
        return data;
      } catch (e) {
        debugPrint('JSON Decode Error: $e');
        throw Exception('Invalid JSON format');
      }
    } else {
      throw Exception(
          'Failed to load appointments (Status: ${response.statusCode})');
    }
  }

  Future<void> fetchAndSetSchedules({int? year}) async {
    
    year ??= DateTime.now().year;

    DateTime now = DateTime(DateTime.now().year, 1, 1);
    DateTime end = DateTime(DateTime.now().year, 12, 31, 23, 59, 59);
    int limit = 10;
    int offset = 0;

    final UserModel user = await getUserDetails();

    List<dynamic> combinedData = [];

    for (String status2 in ['upcoming', 'completed', 'cancelled']) {
      try {
        final data = await fetchAppointments(
          start: now,
          end: end,
          status2: status2,
          limit: limit,
          offset: offset,
          user_id: user.userId!,
          role: user.userId!,
        );

        combinedData.addAll(data);
      } catch (e) {
        debugPrint('Error fetching $status2 appointments: $e');
      }
    }

    setState(() {
      schedules = combinedData
          .map((item) {
            try {
              DateTime dateTime;
              String formattedTime =
                  "00:00"; // Default time is set to "00:00" (midnight)

              // Diagnostic log to check values of masa_mula and tarikh
              debugPrint('masa_mula: ${item['masa_mula']}');
              debugPrint('tarikh: ${item['tarikh']}');

              // First, check if masa_mula exists and is not empty
              if (item['masa_mula'] != null && item['masa_mula'].isNotEmpty) {
                // Parse masa_mula if it exists and is not empty
                dateTime = DateTime.parse(item['masa_mula']);
                formattedTime = TimeOfDay.fromDateTime(dateTime)
                    .format(context); // Get formatted time
              } else if (item['tarikh'] != null && item['tarikh'].isNotEmpty) {
                // If masa_mula is null, fall back to tarikh
                dateTime = DateTime.parse(item['tarikh']);

                // Manually set time to "00:00" if masa_mula is not available
                // Assuming tarikh is a date in the form "YYYY-MM-DD"
                formattedTime =
                    ""; // Default to midnight if no time is provided
              } else {
                // Both masa_mula and tarikh are missing, log the error and throw the exception
                debugPrint('Both masa_mula and tarikh are null or empty');
                throw Exception("Both masa_mula and tarikh are null or empty");
              }

              // Format the date in "YYYY-MM-DD" format
              String formattedDate =
                  "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
              String formattedDatelocal =
                  "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";

              return {
                'id': item['id'],
                'doctor_name': item['nama'],
                'doctor_profile':
                    "${Config.base_url}/assets/img/user/${item['user_id']}/${item['image_url']!}",
                'category': 'Kaunseling',
                'status': item['status2'] == 'upcoming'
                    ? FilterStatus.upcoming
                    : item['status2'] == 'completed'
                        ? FilterStatus.completed
                        : FilterStatus.cancelled,
                'schedule': {
                  'title': item['masalah'],
                  'date': formattedDate,
                  'local_date': formattedDatelocal,
                  'time':
                      formattedTime, // Time will be "00:00" if not available
                  'status': item['status'],
                },
              };
            } catch (e) {
              debugPrint('Error parsing masa_mula or tarikh: $e');
              return null;
            }
          })
          .where((item) => item != null)
          .toList();

      isLoading = false;
    });
  }

   @override
  Widget build(BuildContext context) {
    // Filter schedules by selected status and date
    List<dynamic> filteredSchedules = schedules.where((schedule) {
      bool matchesStatus = schedule['status'] == status;

      String selectedDateFormatted =
          DateFormat('yyyy-MM-dd').format(_selectedDate);
      String scheduleDate = schedule['schedule']['date'];

      bool matchesDate = scheduleDate == selectedDateFormatted;

      return matchesStatus && matchesDate;
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Appointment Schedule',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => fetchAndSetSchedules(),
                  child: FaIcon(FontAwesomeIcons.rotate),
                ),
              ],
            ),
            EasyDateTimeLinePicker(
              focusedDate: _selectedDate,
              firstDate: DateTime(2024, 3, 18),
              lastDate: DateTime(2030, 3, 18),
              onDateChange: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              monthYearPickerOptions: MonthYearPickerOptions(
                initialCalendarMode: EasyDatePickerMode.month,
                cancelText: 'Cancel',
                confirmText: 'Confirm',
              ),
              timelineOptions: TimelineOptions(
                height: 70,
              ),
            ),
            Config.spaceSmall,
            Stack(
              children: [
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: FilterStatus.values.map((filterStatus) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              status = filterStatus;
                              _alignment = filterStatus == FilterStatus.upcoming
                                  ? Alignment.centerLeft
                                  : filterStatus == FilterStatus.completed
                                      ? Alignment.center
                                      : Alignment.centerRight;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              filterStatus.name,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                AnimatedAlign(
                  alignment: _alignment,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: Config.widthSize * 0.33,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Config.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        status.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Config.spaceSmall,
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredSchedules.isEmpty
                      ? Center(child: Text("No appointments found."))
                      : ListView.builder(
                          itemCount: filteredSchedules.length,
                          itemBuilder: (context, index) {
                            var schedule = filteredSchedules[index];
                            return ScheduleCard(
                              imageUrl: schedule['doctor_profile'] ?? '',
                              name: schedule['doctor_name'] ?? 'Unknown',
                              category: schedule['category'] ?? 'Kaunselor',
                              title:
                                  schedule['schedule']['title'] ?? 'No Title',
                              date: schedule['schedule']['local_date'] ?? '',
                              time: schedule['schedule']['time'] ?? '',
                              status:
                                  _mapStatus(schedule['schedule']['status']),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        AppointmentDetailsPage2(
                                            id: schedule['id'].toString()),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
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
