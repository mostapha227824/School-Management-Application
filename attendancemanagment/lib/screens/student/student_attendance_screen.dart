import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final String studentId;

  const StudentAttendanceScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  String? selectedClassId;
  List<DocumentSnapshot> classDocs = [];
  List<Map<String, dynamic>> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  // Fetch all classes
  Future<void> fetchClasses() async {
    final snapshot = await FirebaseFirestore.instance.collection('classes').get();
    setState(() {
      classDocs = snapshot.docs;
    });
  }

  // Fetch attendance for the selected class and student
  Future<void> fetchAttendance() async {
    if (selectedClassId == null) {
      print('No class selected, skipping attendance fetch.');
      return;
    }

    print('Fetching attendance for class: $selectedClassId and student: ${widget.studentId}');

    final classRef = FirebaseFirestore.instance.collection('classes').doc(selectedClassId);
    final attendanceRef = classRef.collection('attendance');
    final snapshot = await attendanceRef.get();

    List<Map<String, dynamic>> fetchedRecords = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final rawDate = data?['date'];
      final attendanceList = data?['attendance'];

      DateTime date = rawDate is Timestamp ? rawDate.toDate() : DateTime.now();

      if (attendanceList != null && attendanceList is List) {
        for (var entry in attendanceList) {
          print("Entry studentId: ${entry['studentId']}, isPresent: ${entry['isPresent']}");
          if (entry['studentId'] == widget.studentId) {
            fetchedRecords.add({
              'date': date,
              'isPresent': entry['isPresent'] ?? false,
            });
          }
        }
      }
    }

    print("Found ${fetchedRecords.length} attendance records for student: ${widget.studentId}");

    setState(() {
      attendanceRecords = fetchedRecords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Dropdown to select class
            DropdownButton<String>(
              hint: const Text("Select Class"),
              value: selectedClassId,
              isExpanded: true,
              style: const TextStyle(color: Colors.black), // Direct custom style
              items: classDocs.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(
                    doc['name'] ?? 'Unknown',
                    style: const TextStyle(color: Colors.black, fontSize: 16), // Direct custom style
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClassId = value;
                  attendanceRecords = [];
                });
                fetchAttendance();
              },
            ),
            const SizedBox(height: 20),
            // Attendance records list
            Expanded(
              child: attendanceRecords.isEmpty
                  ? const Center(child: Text("No attendance records found."))
                  : ListView.builder(
                      itemCount: attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = attendanceRecords[index];
                        final date = record['date'] as DateTime;
                        final isPresent = record['isPresent'] as bool;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                              style: const TextStyle(color: Colors.black, fontSize: 18), // Direct custom style
                            ),
                            trailing: Icon(
                              isPresent ? Icons.check_circle : Icons.cancel,
                              color: isPresent ? Colors.green : Colors.red,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
