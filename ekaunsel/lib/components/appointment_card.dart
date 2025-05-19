import 'package:flutter/material.dart';
import 'package:ekaunsel/utils/config.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({super.key});

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
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
              children: <Widget>[
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/pickauselor.jpg',
                      ), //imagen de doctor
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Text(
                          'Puan Syaza',
                          style: TextStyle(
                            color: Config.blackColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text('Kaunselor',
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ],
                ),
                Config.spaceSmall,
                //Schedule info
                ScheduleCard(
                  title: 'Kelangsungan Hidup',
                  date: 'Monday, 25/04/2025',
                  time: '12:00 PM',
                  status: 'Online',
                  onTap: () {
                    // Action when the card is tapped
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on Monday schedule!')),
                    );
                  },
                ),
                Config.spaceSmall,
                //Action button
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Expanded(
                //       child: ElevatedButton(
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.white,
                //         ),
                //         child: const Text(
                //           'Cancel',
                //           style: TextStyle(color: Config.cancelColor),
                //         ),
                //         onPressed: () {},
                //       ),
                //     ),
                //     const SizedBox(width: 20),
                //     Expanded(
                //       child: Text(""),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class ScheduleCard extends StatelessWidget {
  final String date;
  final String time;
  final String title;
  final String status;
  final VoidCallback onTap; // Added callback for gesture behavior

  const ScheduleCard({
    super.key,
    required this.date,
    required this.time,
    required this.status,
    required this.title,
    required this.onTap, // Initialize gesture behavior
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // This will trigger the onTap callback when tapped
      child: Container(
        decoration: BoxDecoration(
          color: Config.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 5),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.calendar_today, color: Colors.white, size: 15),
                SizedBox(width: 5),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(width: 20),
                // Only show the time section if time is not empty or null
                if (time.isNotEmpty) ...[
                  Icon(Icons.access_alarm, color: Colors.white, size: 17),
                  SizedBox(width: 5),
                  Flexible(
                    child: Text(time, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  status,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
