import 'package:flutter/material.dart';
import 'package:attendancemanagment/screens/teacher/teacher_attendance_taking_screen.dart';
import 'package:attendancemanagment/screens/teacher/teacher_grade_taking_screen.dart';
import '../../services/auth_service.dart';

class TeacherDashboard extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Teacher Dashboard",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Direct style for title
        ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to the Teacher Dashboard',
                      style: TextStyle(
                        fontSize: 24, // Custom font size
                        fontWeight: FontWeight.bold, // Bold text style
                        color: Colors.black, // Default color for the text
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherAttendanceTakingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Go to Attendance Taking'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherGradeTakingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Go to Grade Taking'),
                    ),
                    const SizedBox(height: 20),
                    Spacer(), // Push everything up if there's extra space
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
