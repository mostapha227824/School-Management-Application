import 'package:flutter/material.dart';
import '../admin/add_class_page.dart';
import '../admin/manage_class_students_page.dart';
import '../../services/auth_service.dart'; // Import your auth service

class AdminDashboard extends StatelessWidget {
  final AuthService _auth = AuthService(); // Instantiate AuthService

  AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme
    final textStyle = theme.textTheme.titleLarge; // Get titleLarge text style from theme

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: theme.primaryColor, // Use theme's primary color for consistency
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();  // Call the signOut function from AuthService
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
              trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color), // Icon color from theme
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddClassPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.people, color: theme.iconTheme.color), // Icon color from theme
              title: Text('Manage Class Students', style: textStyle),
              trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color), // Icon color from theme
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageClassStudentsPage()),
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
