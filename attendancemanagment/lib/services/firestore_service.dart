// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adds a grade for a student in a given class and semester
  Future<void> addGrade({
    required String classId,
    required String semesterId,
    required String studentId,
    required String grade,
  }) async {
    try {
      final classRef = _firestore.collection('classes').doc(classId);
      final semesterRef = classRef.collection('semesters').doc(semesterId);

      await semesterRef.update({
        'grades': FieldValue.arrayUnion([
          {
            'studentId': studentId,
            'grade': grade,
          }
        ]),
      });

      debugPrint('Grade added for student $studentId in class $classId, semester $semesterId');
    } catch (e) {
      debugPrint("Error adding grade for student $studentId: $e");
    }
  }

  // Fetch grades for a specific student in a specific class
  Future<List<Map<String, dynamic>>> fetchGrades({
    required String classId,
    required String studentId,
  }) async {
    try {
      final classRef = _firestore.collection('classes').doc(classId);
      final semestersSnapshot = await classRef.collection('semesters').get();

      List<Map<String, dynamic>> fetchedGrades = [];

      for (var semesterDoc in semestersSnapshot.docs) {
        final semesterData = semesterDoc.data();
        final gradesList = semesterData['grades'];

        if (gradesList != null) {
          for (var entry in gradesList) {
            if (entry['studentId'] == studentId) {
              fetchedGrades.add({
                'semester': semesterDoc.id,
                'grade': entry['grade'],
              });
            }
          }
        }
      }

      return fetchedGrades;
    } catch (e) {
      debugPrint("Error fetching grades for student $studentId: $e");
      return [];
    }
  }
}
