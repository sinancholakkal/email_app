part of 'email_details_bloc.dart';

@immutable
sealed class EmailDetailsState {}

final class EmailDetailsInitial extends EmailDetailsState {}

final class EmailDetailsLoading extends EmailDetailsState {}

final class EmailDetailsLoaded extends EmailDetailsState {
  final Email email;
  EmailDetailsLoaded({required this.email});
}

final class EmailDetailsError extends EmailDetailsState {
  final String message;
  EmailDetailsError({required this.message});
}
