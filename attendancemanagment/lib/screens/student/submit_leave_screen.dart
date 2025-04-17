import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubmitLeaveScreen extends StatefulWidget {
  final String studentId;

  const SubmitLeaveScreen({super.key, required this.studentId});

  @override
  State<SubmitLeaveScreen> createState() => _SubmitLeaveScreenState();
}

class _SubmitLeaveScreenState extends State<SubmitLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  String leaveType = 'Sick';
  String reason = '';
  DateTime selectedDate = DateTime.now();

  Future<void> submitLeaveRequest() async {
    try {
      await FirebaseFirestore.instance.collection('leave_requests').add({
        'studentId': widget.studentId,
        'leaveType': leaveType,
        'reason': reason,
        'date': selectedDate.toIso8601String(),
        'status': 'Pending', // default
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave request submitted!')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error submitting leave request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit leave request.')),
      );
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Leave Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Leave Type
              DropdownButtonFormField<String>(
                value: leaveType,
                decoration: const InputDecoration(labelText: 'Leave Type'),
                items: ['Sick', 'Personal', 'Emergency']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => leaveType = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              // Reason
              TextFormField(
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a reason' : null,
                onChanged: (value) => reason = value,
              ),
              const SizedBox(height: 20),
              // Date Picker
              Row(
                children: [
                  const Text("Leave Date: "),
                  TextButton(
                    onPressed: () => pickDate(context),
                    child: Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitLeaveRequest();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
