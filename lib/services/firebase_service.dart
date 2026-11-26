import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isFirebaseAvailable = false;
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  bool get isFirebaseAvailable => _isFirebaseAvailable;
  FirebaseAuth? get auth => _auth;
  FirebaseFirestore? get firestore => _firestore;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _auth = FirebaseAuth.instance;
        _isFirebaseAvailable = true;
        debugPrint('Firebase & Auth is connected and active.');
      } else {
        _isFirebaseAvailable = false;
        debugPrint('Firebase not configured natively. Using reactive store with fallback.');
      }
    } catch (e) {
      _isFirebaseAvailable = false;
      debugPrint('Firebase initialization notice: $e');
    }
  }

  // --- AUTH & RBAC ---
  Future<AppUser?> signInWithEmailPassword(String email, String password) async {
    if (!_isFirebaseAvailable || _auth == null || _firestore == null) {
      // Local fallback for testing RBAC without cloud credentials
      final role = (email.contains('admin') || password.contains('admin'))
          ? UserRole.admin
          : UserRole.resident;
      return AppUser(
        uid: 'user_${email.hashCode.abs()}',
        email: email,
        displayName: role == UserRole.admin ? 'City Admin' : 'Resident User',
        role: role,
      );
    }

    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return null;

      final doc = await _firestore!.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, uid);
      } else {
        // Default role based on email or create document
        final role = email.contains('admin') ? UserRole.admin : UserRole.resident;
        final appUser = AppUser(
          uid: uid,
          email: email,
          displayName: credential.user?.displayName ?? (role == UserRole.admin ? 'Administrator' : 'Resident'),
          role: role,
        );
        await _firestore!.collection('users').doc(uid).set(appUser.toMap());
        return appUser;
      }
    } catch (e) {
      debugPrint('Firebase Auth signIn error: $e');
      rethrow;
    }
  }

  Future<AppUser?> signUpWithEmailPassword(String email, String password, String displayName, UserRole role) async {
    if (!_isFirebaseAvailable || _auth == null || _firestore == null) {
      return AppUser(
        uid: 'user_${email.hashCode.abs()}',
        email: email,
        displayName: displayName,
        role: role,
      );
    }

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return null;

      final appUser = AppUser(
        uid: uid,
        email: email,
        displayName: displayName,
        role: role,
      );
      await _firestore!.collection('users').doc(uid).set(appUser.toMap());
      return appUser;
    } catch (e) {
      debugPrint('Firebase Auth signUp error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_isFirebaseAvailable && _auth != null) {
      await _auth!.signOut();
    }
  }

  // --- SAVED LOCATIONS ---
  Future<void> syncSavedLocation(SavedLocation location, String userId) async {
    if (!_isFirebaseAvailable || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('saved_locations')
          .doc(location.id)
          .set(location.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing location to Firebase: $e');
    }
  }

  Future<void> deleteSavedLocation(String id, String userId) async {
    if (!_isFirebaseAvailable || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('saved_locations')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('Error deleting location from Firebase: $e');
    }
  }

  // --- FLOOD ZONES (ADMIN ONLY WRITE) ---
  Future<void> syncFloodZone(FloodZone zone) async {
    if (!_isFirebaseAvailable || _firestore == null) return;
    try {
      await _firestore!
          .collection('flood_zones')
          .doc(zone.id)
          .set(zone.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing flood zone to Firebase: $e');
    }
  }

  // --- REPORTS ---
  Future<void> submitReport(FloodReport report) async {
    if (!_isFirebaseAvailable || _firestore == null) return;
    try {
      await _firestore!
          .collection('flood_reports')
          .doc(report.id)
          .set(report.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error submitting report to Firebase: $e');
    }
  }

  Future<void> updateReportStatus(String id, ReportStatus status, {String? rejectionReason}) async {
    if (!_isFirebaseAvailable || _firestore == null) return;
    try {
      final data = {
        'status': status.name,
      };
      if (rejectionReason != null) {
        data['rejectionReason'] = rejectionReason;
      }
      await _firestore!
          .collection('flood_reports')
          .doc(id)
          .update(data);
    } catch (e) {
      debugPrint('Error updating report in Firebase: $e');
    }
  }
}
