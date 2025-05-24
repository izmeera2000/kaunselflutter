import 'package:ekaunsel/components/button.dart';
import 'package:ekaunsel/components/custom_appbar.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // You need to import this for date formatting
// For json encoding
import 'package:http/http.dart' as http; // For making HTTP requests
// Ensure this import is correct
import 'package:shared_preferences/shared_preferences.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  //declaration
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  bool _isWeekend = false;
  bool _dateSelected = false;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: 'Appointment',
        icon: const FaIcon(Icons.arrow_back_ios),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _tableCalendar(),
              ],
            ),
          ),
          _isWeekend
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 30,
                    ),
                    alignment: Alignment.center,
                  ),
                )
              : SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 30,
                    ),
                    alignment: Alignment.center,
                  ),
                ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 80),
              child: Button(
                width: double.infinity,
                title: 'Make Appointment',
                onPressed: () {
                  // If weekend or no date selected, display an alert or handle accordingly
                  _showConfirmationDialog();
                },
                disable: !_isWeekend && _dateSelected ? false : true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //table calendar
  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2025, 12, 31),
      calendarFormat: _format,
      enabledDayPredicate: (day) =>
          day.weekday != DateTime.saturday && day.weekday != DateTime.sunday,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          if (day.weekday == DateTime.saturday ||
              day.weekday == DateTime.sunday) {
            return const SizedBox.shrink(); // Hide weekends
          }
          return null;
        },
      ),
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Config.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: ((selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;

          //check if weekend is selected
          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;

            // Show the dialog when a weekend is selected
            _showWeekendDialog();
          } else {
            _isWeekend = false;
          }
        });
      }),
    );
  }

  // Function to show the AlertDialog
  void _showWeekendDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Weekend Not Available'),
          content: const Text(
              'Weekend is not available, please select another date'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog() {
    // Format the selected date to display it nicely
    String formattedDate = DateFormat('yyyy-MM-dd').format(_currentDay);

    // TextEditingController to capture the user input
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Config.whiteColor,
          title: const Text('Confirm Appointment'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Display the selected date
                Text('You have selected:  ',
                    style: TextStyle(
                      fontSize: 16,
                    )),
                Text('$formattedDate',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(
                    height: 20), // Add some space between date and text input
                Text('Masalah',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(
                    height: 20), // Add some space between date and text input

                // Input form for additional information (e.g., notes, special requests)
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Masalah',
                    hintText: 'Nyatakan Masalah Anda',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            
            // Confirm Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Capture user input and selected date
                String userInput = _controller.text;

                // Retrieve user ID from SharedPreferences
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                String? userId = prefs.getString('user_id');

                if (userId != null) {
                  // Prepare the data to send to PHP
                  Map<String, String> appointmentData = {
                    'calendaraddna[title]': userInput,
                    'calendaraddna[start]': formattedDate,
                    'calendaraddna[user_id]': userId, // Use actual user ID here
                    'calendaraddna[type]': '1', // Example type
                  };

                  // Send data to the PHP server using a POST request
                  final response = await http.post(
                    Uri.parse(
                        '${Config.base_url}/calendaraddna'), // Replace with your PHP script URL
                    body: appointmentData,
                  );

                  // Handle the response from the PHP server
                  if (response.statusCode == 200) {
                    // Successfully sent data to server
                    debugPrint(
                        'Appointment confirmed for $formattedDate with notes: $userInput');
                    debugPrint('Response Body: ${response.body}');

                    // Close the dialog and navigate to success screen
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(
                        'success_booking'); // Navigate to success page
                  } else {
                    // Handle server error or failure
                    debugPrint(
                        'Failed to make appointment. Server response: ${response.statusCode}');
                    // You can show a Snackbar or a Toast message here
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Failed to make appointment. Please try again later.'),
                      ),
                    );
                  }
                } else {
                  // Handle the case where the user ID is not found in SharedPreferences
                  debugPrint('User ID not found in SharedPreferences');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User ID not found. Please log in again.'),
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
            // Cancel Button
          ],
        );
      },
    );
  }
}
