part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}
class GoogleSignInEvent extends AuthEvent {}
class GoogleSignOutEvent extends AuthEvent {}