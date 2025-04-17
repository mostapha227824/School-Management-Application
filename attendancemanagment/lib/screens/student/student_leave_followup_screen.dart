import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentLeaveFollowUpScreen extends StatelessWidget {
  final String studentId;

  const StudentLeaveFollowUpScreen({super.key, required this.studentId});

  // Function to parse date either from String or Timestamp
  DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate(); // Convert Timestamp to DateTime
    } else if (date is String) {
      try {
        return DateTime.parse(date); // Convert String to DateTime
      } catch (e) {
        return DateTime.now(); // If error occurs, return current time
      }
    }
    return DateTime.now(); // If the date is not a Timestamp or String, return current time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Request Status'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leave_requests')
            .where('studentId', isEqualTo: studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No leave requests submitted.'));
          }

          final leaveRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: leaveRequests.length,
            itemBuilder: (context, index) {
              final leaveRequest = leaveRequests[index];
              final leaveType = leaveRequest['leaveType'];
              final reason = leaveRequest['reason'];
              final status = leaveRequest['status'];

              // Parse the date (either String or Timestamp)
              final leaveDate = parseDate(leaveRequest['date']);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Leave Type: $leaveType'),
                  subtitle: Text(
                    'Reason: $reason\nDate: ${leaveDate.toLocal()}',
                  ),
                  trailing: Text(
                    'Status: $status',
                    style: TextStyle(
                      color: status == 'Approved' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
