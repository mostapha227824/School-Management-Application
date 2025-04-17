import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/leave_service.dart'; // Import the service for fetching leave requests

class LeaveRequestsPage extends StatefulWidget {
  const LeaveRequestsPage({Key? key}) : super(key: key);

  @override
  _LeaveRequestsPageState createState() => _LeaveRequestsPageState();
}

class _LeaveRequestsPageState extends State<LeaveRequestsPage> {
  late Stream<QuerySnapshot> _leaveRequestsStream;

  @override
  void initState() {
    super.initState();
    _leaveRequestsStream = FirebaseFirestore.instance
        .collection('leave_requests')
        .where('status', isEqualTo: 'Pending') // Only fetch pending requests
        .snapshots(); // Real-time stream of leave requests
  }

  // Function to update the leave request status (approve or reject)
  Future<void> updateLeaveStatus(String docId, String status, String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(docId)
          .update({'status': status});
          
      // After updating the leave request, notify the student (This can also be an FCM notification)
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .collection('notifications')
          .add({
            'message': 'Your leave request has been $status.',
            'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave request $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating leave request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _leaveRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No leave requests found.'));
          } else {
            final leaveRequests = snapshot.data!.docs;

            return ListView.builder(
              itemCount: leaveRequests.length,
              itemBuilder: (context, index) {
                final leave = leaveRequests[index];
                final leaveData = leave.data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Student ID: ${leaveData['studentId']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${leaveData['leaveType']}'),
                        Text('Date: ${leaveData['date']}'),
                        Text('Reason: ${leaveData['reason']}'),
                      ],
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => updateLeaveStatus(
                              leave.id, 'Approved', leaveData['studentId']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () => updateLeaveStatus(
                              leave.id, 'Rejected', leaveData['studentId']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
