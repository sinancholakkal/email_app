part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

//Google Sign In
final class AuthInitial extends AuthState {}
final class GoogleSignInLoading extends AuthState {}
final class GoogleSignInSuccess extends AuthState {}
final class GoogleSignInFailure extends AuthState {
  final String error;
  GoogleSignInFailure({required this.error});
}

//Google Sign Out
final class GoogleSignOutLoading extends AuthState {}
final class GoogleSignOutSuccess extends AuthState {}
final class GoogleSignOutFailure extends AuthState {
  final String error;
  GoogleSignOutFailure({required this.error});
}

//Get Current User
final class GetCurrentUserLoading extends AuthState {}
final class GetCurrentUserSuccess extends AuthState {
  final GoogleSignInAccount? user;
  GetCurrentUserSuccess({required this.user});
}
final class GetCurrentUserFailure extends AuthState {
  final String error;
  GetCurrentUserFailure({required this.error});
}