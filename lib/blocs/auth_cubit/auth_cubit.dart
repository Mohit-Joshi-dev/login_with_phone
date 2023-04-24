import 'dart:developer';

import 'package:assessment/models/user_model.dart' as model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// verify phone number with [FirebaseAuth]
  void verifyPhoneNumber(
      {required String countrycode, required String mobileNumber}) async {
    emit(AuthVerificationLoading());
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: countrycode + mobileNumber,
        timeout: const Duration(seconds: 15),
        verificationCompleted: (phoneAuthCredential) {
          // _signInWithPhoneNumber(credential: phoneAuthCredential);
          log('SHowing completed');
        },
        verificationFailed: (error) {
          emit(AuthVerificationFBError(error: error));
        },
        codeSent: (verificationId, forceResendingToken) {
          emit(AuthVerificationCodeSent(verificationId: verificationId));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          //TODO: handle this case if needed.
        },
      );
    } catch (e) {
      emit(AuthVerificationError(error: e.toString()));
    }
  }

  /// sign in with phone number with [FirebaseAuth]
  void signInWithPhoneNumber(
      {required String verificationId, required String otp}) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final User? user = (await _auth.signInWithCredential(credential)).user;
      final User? currentUser = _auth.currentUser;
      assert(user?.uid == currentUser?.uid);
      if (user != null) {
        emit(AuthVerificationSuccess(
            user: model.User(
          id: user.uid,
          email: user.email,
          mobile: user.phoneNumber,
          name: user.displayName,
        )));
      } else {
        emit(AuthVerificationError(error: 'Sign In Failed'));
      }
    } catch (e) {
      emit(AuthVerificationError(error: e.toString()));
    }
  }
}
