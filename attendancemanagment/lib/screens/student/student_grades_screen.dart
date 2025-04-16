import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentGradesScreen extends StatefulWidget {
  final String studentId;

  const StudentGradesScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  String? selectedClassId;
  String? selectedClassName;
  List<DocumentSnapshot> classDocs = [];
  List<Map<String, dynamic>> gradeRecords = [];

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  // Fetch available classes
  Future<void> fetchClasses() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('classes').get();
      setState(() {
        classDocs = snapshot.docs;
      });
      print('Fetched ${snapshot.docs.length} classes');
    } catch (e) {
      print('Error fetching classes: $e');
    }
  }

  // Fetch grades based on the selected class and student
  Future<void> fetchGrades() async {
    if (selectedClassId == null || selectedClassName == null) {
      print('Class not selected properly.');
      return;
    }

    print('Fetching grades for class: $selectedClassId and student: ${widget.studentId}');

    final gradesDocRef = FirebaseFirestore.instance
        .collection('classes')
        .doc(selectedClassId)
        .collection('grades')
        .doc(selectedClassName); // new logic: class name is document ID

    try {
      final gradesDoc = await gradesDocRef.get();

      List<Map<String, dynamic>> fetchedRecords = [];

      if (gradesDoc.exists) {
        final data = gradesDoc.data();
        print('Grades Doc Data: $data');

        final gradesList = data?['grades'] as List<dynamic>?;

        if (gradesList != null) {
          for (var entry in gradesList) {
            if (entry['studentId'] == widget.studentId) {
              fetchedRecords.add({
                'class': selectedClassName,
                'grade': entry['grade']?.toString() ?? 'N/A',
              });
            }
          }
        } else {
          print('No grades list found.');
        }
      } else {
        print('Grades document does not exist.');
      }

      print("Found ${fetchedRecords.length} grade records for student: ${widget.studentId}");

      setState(() {
        gradeRecords = fetchedRecords;
      });
    } catch (e) {
      print('Error fetching grades: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grades'),
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
              style: TextStyle(color: Colors.black),
              items: classDocs.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(
                    doc['name']?.toString() ?? 'Unknown',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClassId = value;
                  selectedClassName = classDocs
                      .firstWhere((doc) => doc.id == value)?['name'] ?? 'Unknown';
                  gradeRecords = [];
                });
                fetchGrades();
              },
            ),
            const SizedBox(height: 20),
            // Grades list
            Expanded(
              child: gradeRecords.isEmpty
                  ? const Center(child: Text("No grade records found."))
                  : ListView.builder(
                      itemCount: gradeRecords.length,
                      itemBuilder: (context, index) {
                        final record = gradeRecords[index];
                        final className = record['class'];
                        final grade = record['grade'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              "Class: $className",
                              style: TextStyle(color: Colors.black, fontSize: 18),
                            ),
                            subtitle: Text(
                              "Grade: $grade",
                              style: TextStyle(color: Colors.black54, fontSize: 16),
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
