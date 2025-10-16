part of 'sended_email_bloc.dart';



sealed class SendedEmailEvent {}
class LoadSendedDataEvent extends SendedEmailEvent{}
class RefreshSendedDataEvent extends SendedEmailEvent{}