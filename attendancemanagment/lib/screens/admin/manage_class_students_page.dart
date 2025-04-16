import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ManageClassStudentsPage extends StatefulWidget {
  const ManageClassStudentsPage({super.key});

  @override
  ManageClassStudentsPageState createState() => ManageClassStudentsPageState();
}

class ManageClassStudentsPageState extends State<ManageClassStudentsPage> {
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> availableStudents = [];
  String? selectedClassId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

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

  Future<void> _loadAvailableStudents() async {
    if (selectedClassId == null) return;

    final classDoc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(selectedClassId)
        .get();
    if (!classDoc.exists) return;

    List<dynamic> studentIds = classDoc['assignedStudents'];

    final studentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    if (!mounted) return;
    setState(() {
      availableStudents = studentSnapshot.docs
          .where((doc) => !studentIds.contains(doc.id))
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }

  Future<void> _addStudentToClass(String studentId) async {
    if (selectedClassId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(selectedClassId)
            .update({
          'assignedStudents': FieldValue.arrayUnion([studentId]),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added to class')),
        );

        _loadAvailableStudents();
      } catch (e) {
        debugPrint("Error adding student to class: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Class Students"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.class_, color: Colors.deepPurple),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text("Select a Class"),
                                value: selectedClassId,
                                onChanged: (value) {
                                  setState(() {
                                    selectedClassId = value;
                                    _loadAvailableStudents();
                                  });
                                },
                                items: classes.map((classData) {
                                  return DropdownMenuItem<String>(
                                    value: classData['id'],
                                    child: Text(
                                      classData['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: availableStudents.isEmpty
                        ? const Center(
                            child: Text(
                              'No students available to add',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: availableStudents.length,
                            itemBuilder: (context, index) {
                              final student = availableStudents[index];
                              return Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    student['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: theme.colorScheme.primary,
                                    onPressed: () =>
                                        _addStudentToClass(student['id']),
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
