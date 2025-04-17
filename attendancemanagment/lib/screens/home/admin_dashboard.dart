import 'package:flutter/material.dart';
import '../admin/add_class_page.dart';
import '../admin/manage_class_students_page.dart';
import '../admin/leave_requests_page.dart'; 
import '../../services/auth_service.dart'; 

class AdminDashboard extends StatelessWidget {
  final AuthService _auth = AuthService(); 

  AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Geting current theme
    final textStyle = theme.textTheme.titleLarge; // Geting titleLarge text style from theme

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: theme.primaryColor, // Using theme's primary color for consistency
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();  
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/'); // Redirect to login page
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the ListView for better spacing
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.class_, color: theme.iconTheme.color), // Icon color from theme
              title: Text('Add Classes', style: textStyle),
              trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddClassPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.people, color: theme.iconTheme.color),
              title: Text('Manage Class Students', style: textStyle),
              trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageClassStudentsPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.assignment, color: theme.iconTheme.color),
              title: Text('View Leave Requests', style: textStyle),
              trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaveRequestsPage(),
                  ),
                );
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
