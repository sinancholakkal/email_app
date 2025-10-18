part of 'email_details_bloc.dart';

@immutable
sealed class EmailDetailsEvent {}

class FetchEmailDetailsEvent extends EmailDetailsEvent {
  final String emailId;
  FetchEmailDetailsEvent({required this.emailId});
}

class IstarrEventEmailDetails extends EmailDetailsEvent {
  final String messageId;
  final bool shouldStar;
  IstarrEventEmailDetails({required this.messageId, required this.shouldStar});
}