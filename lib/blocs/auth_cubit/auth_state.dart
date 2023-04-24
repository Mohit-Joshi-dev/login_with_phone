part of 'auth_cubit.dart';

abstract class AuthState {
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthVerificationLoading extends AuthState {}

class AuthVerificationSuccess extends AuthState {
  AuthVerificationSuccess({required this.user});

  final model.User user;

  @override
  List<Object> get props => [
        user,
      ];
}

class AuthVerificationCodeSent extends AuthState {
  AuthVerificationCodeSent({required this.verificationId});

  final String verificationId;

  @override
  List<Object> get props => [
        verificationId,
      ];
}

class AuthVerificationError extends AuthState {
  AuthVerificationError({required this.error});

  final String error;

  @override
  List<Object> get props => [
        error,
      ];
}

class AuthVerificationFBError extends AuthState {
  AuthVerificationFBError({required this.error});

  final FirebaseAuthException error;

  @override
  List<Object> get props => [
        error,
      ];
}
