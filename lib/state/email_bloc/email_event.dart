part of 'email_bloc.dart';

@immutable
sealed class EmailEvent {}
class LoadDataEvent extends EmailEvent{}
class RefreshDataEvent extends EmailEvent{}
class IstarrEventHome extends EmailEvent{
   final String messageId;
  final bool shouldStar;
  IstarrEventHome({required this.messageId, required this.shouldStar});
}
class TrashEmailEvent extends EmailEvent{
  final String messageId;
  TrashEmailEvent({required this.messageId});
}
class MarkEmailAsReadEvent extends EmailEvent{
  final String emailId;
  final int emailIndex;
  MarkEmailAsReadEvent({required this.emailId, required this.emailIndex});
}