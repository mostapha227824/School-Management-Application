import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TeacherAttendanceTakingScreen extends StatefulWidget {
  @override
  _TeacherAttendanceTakingScreenState createState() =>
      _TeacherAttendanceTakingScreenState();
}

class _TeacherAttendanceTakingScreenState
    extends State<TeacherAttendanceTakingScreen> {
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> students = [];
  String? selectedClassId; // Store the selected class ID
  bool isLoading = true; // Flag to show loading indicator
  DateTime? selectedDate; // Store the selected date for attendance

  @override
  void initState() {
    super.initState();
    _loadClasses(); // Load the classes when the screen is initialized
  }

  // Fetch all classes from Firestore
  Future<void> _loadClasses() async {
    try {
      final classSnapshot =
          await FirebaseFirestore.instance.collection('classes').get();
      if (!mounted) return;

      setState(() {
        classes = classSnapshot.docs
            .map((doc) => {'id': doc.id, 'name': doc['name']})
            .toList();
        isLoading = false; // Set loading flag to false when data is loaded
      });
    } catch (e) {
      debugPrint("Error loading classes: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false; // Set loading flag to false even on error
      });
    }
  }

  // Fetch students for the selected class
  Future<void> _loadStudentsForClass() async {
    if (selectedClassId == null) return;

    try {
      final classDoc =
          await FirebaseFirestore.instance.collection('classes').doc(selectedClassId).get();

      if (!classDoc.exists) return;

      // Assuming the 'assignedStudents' field contains a list of student IDs
      List<dynamic> studentIds = classDoc['assignedStudents'];

      // Fetch the students from Firestore based on the student IDs
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: studentIds)
          .get();

      if (!mounted) return;

      setState(() {
        students = studentSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc['name'],
                  'isPresent': false, // Default attendance status is false (absent)
                })
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading students for class: $e");
    }
  }

  // Update attendance status for a student
  void _updateAttendance(String studentId, bool isPresent) {
    setState(() {
      final studentIndex = students.indexWhere((student) => student['id'] == studentId);
      if (studentIndex != -1) {
        students[studentIndex]['isPresent'] = isPresent;
      }
    });
  }

  // Save attendance to Firestore
  Future<void> _saveAttendance() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date for the attendance!')),
      );
      return;
    }

    // Create a reference to the 'attendance' subcollection in Firestore
    final attendanceRef = FirebaseFirestore.instance
        .collection('classes')
        .doc(selectedClassId)
        .collection('attendance')
        .doc(DateFormat('yyyyMMdd').format(selectedDate!)); // Using the date as document ID

    // Prepare attendance data to be saved
    final attendanceData = students
        .map((student) => {
              'studentId': student['id'],
              'isPresent': student['isPresent'],
            })
        .toList();

    try {
      // Save attendance data to Firestore
      await attendanceRef.set({
        'date': selectedDate,
        'attendance': attendanceData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance saved successfully for ${DateFormat.yMd().format(selectedDate!)}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving attendance: $e')),
      );
    }
  }

  // Show date picker to select the attendance date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teacher Attendance Taking"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while data is fetched
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<String>(
                    hint: const Text("Select a Class"),
                    value: selectedClassId,
                    onChanged: (value) {
                      setState(() {
                        selectedClassId = value;
                        students.clear(); // Clear previous students list
                        _loadStudentsForClass(); // Load students for the selected class
                      });
                    },
                    items: classes.map((classData) {
                      return DropdownMenuItem<String>(
                        value: classData['id'],
                        child: Text(classData['name']),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedDate == null
                            ? 'Select Attendance Date'
                            : 'Selected Date: ${DateFormat.yMd().format(selectedDate!)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: selectedClassId == null
                      ? Center(child: Text('Please select a class'))
                      : students.isEmpty
                          ? Center(child: Text('No students assigned to this class'))
                          : ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                final student = students[index];
                                return ListTile(
                                  title: Text(student['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                  trailing: Switch(
                                    value: student['isPresent'],
                                    onChanged: (bool value) {
                                      _updateAttendance(student['id'], value);
                                    },
                                  ),
                                );
                              },
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _saveAttendance,
                    child: Text("Save Attendance", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
    );
  }
}
