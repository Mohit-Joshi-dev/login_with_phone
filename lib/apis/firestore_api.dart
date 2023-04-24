import 'dart:developer';

import 'package:assessment/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreApi {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Creates user in firestore db
  Future<void> createUser({required User user}) async {
    log('user:$user');

    try {
      final userDocument = usersCollection.doc(user.id);
      await userDocument.set(user.toJson());
      log('UserCreated at ${userDocument.path}');
    } catch (error) {
      log(error.toString());
    }
  }

  /// gets already available user from firestore db
  Future<User?> getUser({required String userId}) async {
    log('userId:$userId');

    if (userId.isNotEmpty) {
      final userDoc = await usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        log('We have no user with id $userId in our database');
        return null;
      }

      final userData = userDoc.data();
      log('User found. Data: $userData');

      return User.fromJson(userData! as Map<String, dynamic>);
    } else {
      log('Your userId passed in is empty. Please pass in a valid user if from your Firebase user.');
    }
    return null;
  }

  /// updates name in firestore db
  Future<void> updateName(
      {required String value, required String userId}) async {
    log('userId:$userId');

    if (userId.isNotEmpty) {
      final userDoc = await usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        log('We have no user with id $userId in our database');
      }

      await usersCollection.doc(userId).update({'name': value});
    } else {
      log('Your userId passed in is empty. Please pass in a valid user if from your Firebase user.');
      throw Exception(
          'Your userId passed in is empty. Please pass in a valid user if from your Firebase user.');
    }
  }
}
