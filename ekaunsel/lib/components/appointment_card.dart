import 'package:flutter/material.dart';
import 'package:ekaunsel/utils/config.dart';

class ScheduleCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String category;
  final String title;
  final String date;
  final String time;
  final String status;
  final VoidCallback onTap;

  const ScheduleCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 300, // fixed width for horizontal scroll

          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Config.whiteColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: avatar + name + category
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/default_profile.png')
                            as ImageProvider,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title of the session
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: Config.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                         fontWeight: FontWeight.bold,
                         color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Date & Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white, size: 15),
                        const SizedBox(width: 5),
                        Text(date, style: const TextStyle(color: Colors.white)),
                        const SizedBox(width: 15),
                        if (time.isNotEmpty) ...[
                          const Icon(Icons.access_time,
                              color: Colors.white, size: 15),
                          const SizedBox(width: 5),
                          Text(time,
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Status
                    Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
