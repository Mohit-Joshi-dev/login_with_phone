import 'dart:developer';

import 'package:assessment/apis/firestore_api.dart';
import 'package:assessment/models/user_model.dart';
import 'package:assessment/services/local_db_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserService {
  final _firestoreApi = FirestoreApi();
  // final _firebaseAuthenticationService =
  //     FirebaseAuthenticationService();

  final _firebaseAuth = auth.FirebaseAuth.instance;
  final _localDb = LocalDBService();

  User? _currentUser;

  User get currentUser => _currentUser!;

  bool get hasLoggedInUser => _firebaseAuth.currentUser != null;

  /// sync user account if there is already a user on firebase
  Future<void> syncUserAccount() async {
    final firebaseUserId = _firebaseAuth.currentUser!.uid;

    log('Sync user $firebaseUserId');

    final userAccount = await _firestoreApi.getUser(userId: firebaseUserId);

    if (userAccount != null) {
      log('User account exists. Save as _currentUser');
      _currentUser = userAccount;
      await _localDb.saveUser(userAccount);
    }
  }

  /// creates a user account on firebase if not found any
  Future<void> syncOrCreateUserAccount({required User user}) async {
    log('user:$user');

    await syncUserAccount();

    if (_currentUser == null) {
      log('We have no user account. Create a new user ...');
      await _firestoreApi.createUser(user: user);
      _currentUser = user;
      await _localDb.saveUser(user);
      log('_currentUser has been saved');
    }
  }

  /// updates name on firebase DB
  Future<void> updateName({required String name}) async {
    if (_currentUser != null) {
      await _firestoreApi.updateName(value: name, userId: _currentUser!.id);

      await syncUserAccount();
    }
  }
}
