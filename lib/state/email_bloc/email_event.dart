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