import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherGradeTakingScreen extends StatefulWidget {
  const TeacherGradeTakingScreen({Key? key}) : super(key: key);

  @override
  _TeacherGradeTakingScreenState createState() =>
      _TeacherGradeTakingScreenState();
}

class _TeacherGradeTakingScreenState extends State<TeacherGradeTakingScreen> {
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> students = [];
  String? selectedClassId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
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
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading classes: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch students for the selected class
  Future<void> _loadStudentsForClass() async {
    if (selectedClassId == null) return;

    try {
      final classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(selectedClassId)
          .get();

      if (!classDoc.exists) return;

      List<dynamic> studentIds = classDoc['assignedStudents'];

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
                  'grade': '',
                })
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading students for class: $e");
    }
  }

  // Update grade for a student
  void _updateGrade(String studentId, String grade) {
    setState(() {
      final studentIndex =
          students.indexWhere((student) => student['id'] == studentId);
      if (studentIndex != -1) {
        students[studentIndex]['grade'] = grade;
      }
    });
  }

  // Save grades to Firestore
  Future<void> _saveGrades() async {
    if (selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a class!')),
      );
      return;
    }

    // Find the class name from the classes list
    final selectedClass = classes.firstWhere(
      (classData) => classData['id'] == selectedClassId,
      orElse: () => {'name': 'Unknown'},
    );
    final className = selectedClass['name'];

    final gradesRef = FirebaseFirestore.instance
        .collection('classes')
        .doc(selectedClassId)
        .collection('grades')
        .doc(className); // Use class name as document ID

    final gradesData = students
        .map((student) => {
              'studentId': student['id'],
              'grade': student['grade'],
            })
        .toList();

    try {
      await gradesRef.set({
        'grades': gradesData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grades saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving grades: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teacher Grade Taking"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                        students.clear();
                        _loadStudentsForClass();
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
                                  title: Text(student['name']),
                                  subtitle: Text('Grade: ${student['grade']}'),
                                  trailing: SizedBox(
                                    width: 120,
                                    child: TextField(
                                      onChanged: (grade) {
                                        _updateGrade(student['id'], grade);
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Enter Grade',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _saveGrades,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Corrected button color parameter
                    ),
                    child: Text(
                      "Save Grades",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
