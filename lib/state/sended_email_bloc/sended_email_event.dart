part of 'sended_email_bloc.dart';



sealed class SendedEmailEvent {}
class LoadSendedDataEvent extends SendedEmailEvent{}
class RefreshSendedDataEvent extends SendedEmailEvent{}
class IstarrEventSended extends SendedEmailEvent{
   final String messageId;
  final bool shouldStar;
  IstarrEventSended({required this.messageId, required this.shouldStar});
}