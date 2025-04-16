import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddClassPage extends StatefulWidget {
  const AddClassPage({Key? key}) : super(key: key);

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final TextEditingController _classNameController = TextEditingController();
  List<String> _selectedStudentIds = [];
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentsFromUsersCollection();
  }

  Future<void> _fetchStudentsFromUsersCollection() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    setState(() {
      _students = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unnamed Student',
        };
      }).toList();
    });
  }

  Future<void> _createClass() async {
    final className = _classNameController.text.trim();
    if (className.isEmpty || _selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a class name and select students.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('classes').add({
      'name': className,
      'assignedStudents': _selectedStudentIds,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Class created successfully!')),
    );

    _classNameController.clear();
    setState(() => _selectedStudentIds.clear());
  }

  bool _isSelected(String id) => _selectedStudentIds.contains(id);

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedStudentIds.contains(id)) {
        _selectedStudentIds.remove(id);
      } else {
        _selectedStudentIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Class'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _classNameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  prefixIcon: Icon(Icons.class_),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Assign Students:',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _students.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Scrollbar(
                        child: ListView.builder(
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final isSelected = _isSelected(student['id']);
                            return CheckboxListTile(
                              title: Text(student['name']),
                              value: isSelected,
                              onChanged: (_) => _toggleSelection(student['id']),
                              activeColor: theme.colorScheme.primary,
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createClass,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Class'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
