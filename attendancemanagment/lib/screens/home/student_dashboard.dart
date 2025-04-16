import 'package:flutter/material.dart';
import 'package:attendancemanagment/screens/student/student_attendance_screen.dart';
import 'package:attendancemanagment/screens/student/student_grades_screen.dart'; // Import for grades screen
import '../../services/auth_service.dart';

class StudentDashboard extends StatelessWidget {
  final AuthService _auth = AuthService();
  final String studentId;

  StudentDashboard({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding for spacing
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome to Student Dashboard!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Direct style
              ),
              const SizedBox(height: 40), // Space between text and buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentAttendanceScreen(studentId: studentId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: Theme.of(context).colorScheme.primary, // Apply theme primary color
                  textStyle: TextStyle(fontSize: 16), // Custom style for button text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View Attendance'),
              ),
              const SizedBox(height: 20), // Space between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentGradesScreen(studentId: studentId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: Theme.of(context).colorScheme.secondary, // Apply theme secondary color
                  textStyle: TextStyle(fontSize: 16), // Custom style for button text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View Grades'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
