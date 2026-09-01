import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class FirebaseService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hardcoded Admin Credentials
  static const String adminEmail = 'admin@polioguard.com';
  static const String adminPassword = 'Admin@123';

  Future<FirebaseService> init() async {
    // Create admin account if doesn't exist
    await _ensureAdminExists();
    return this;
  }

  // Ensure admin exists in Firestore
  Future<void> _ensureAdminExists() async {
    try {
      // Check if admin exists in Firestore
      final adminDoc = await _firestore.collection('users').doc('admin').get();

      if (!adminDoc.exists) {
        // Create admin user in Firestore
        await _firestore.collection('users').doc('admin').set({
          'uid': 'admin',
          'email': adminEmail,
          'name': 'System Administrator',
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        print('✅ Admin created in Firestore');
      }
    } catch (e) {
      print('❌ Error ensuring admin exists: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Admin: Create worker account
  Future<bool> createWorkerAccount({
    required String email,
    required String name,
    required String sector,
    required String password, // Common password
  }) async {
    try {
      // 1. Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Save user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email.trim(),
        'name': name,
        'role': 'worker',
        'assignedSector': sector,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid ?? 'admin',
        'isActive': true,
      });

      // 3. Update sector with assigned worker
      await _firestore.collection('sectors').doc(sector).set({
        'sectorId': sector,
        'sectorName': sector,
        'assignedWorkerId': userCredential.user!.uid,
        'assignedWorkerName': name,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('❌ Error creating worker: $e');
      return false;
    }
  }

  // Admin: Get all workers
  Stream<QuerySnapshot> getWorkers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'worker')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  // Admin: Get all sectors
  Stream<QuerySnapshot> getSectors() {
    return _firestore.collection('sectors').snapshots();
  }

  // Admin: Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      print('❌ Error changing password: $e');
      return false;
    }
  }

  // Delete worker (soft delete)
  Future<void> deactivateWorker(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isActive': false,
      'deactivatedAt': FieldValue.serverTimestamp(),
    });
  }
}