import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveService {
  // Fetch leave requests from Firebase Firestore
  static Future<List<Map<String, dynamic>>> fetchLeaveRequests() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('leave_requests')
          .where('status', isEqualTo: 'Pending') // Only fetch pending requests
          .get();

      return snapshot.docs.map((doc) {
        return {
          'studentId': doc['studentId'],
          'leaveType': doc['leaveType'],
          'reason': doc['reason'],
          'date': doc['date'],
          'status': doc['status'],
          'timestamp': doc['timestamp'],
          'docId': doc.id,
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching leave requests: $e');
    }
  }

  // Update the leave request status (approve or reject)
  static Future<void> updateLeaveStatus(String docId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(docId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Error updating leave request status: $e');
    }
  }
}
