part of 'send_email_bloc.dart';

@immutable
sealed class SendEmailState {}

final class SendEmailInitial extends SendEmailState {}
class SendEmailLoadingState extends SendEmailState {}
class SendEmailSuccessState extends SendEmailState {}
class SendEmailErrorState extends SendEmailState {
  final String error;
  SendEmailErrorState({required this.error});
}