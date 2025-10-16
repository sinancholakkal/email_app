part of 'send_email_bloc.dart';

@immutable
sealed class SendEmailEvent {}
class SendIngEmailEvent extends SendEmailEvent{
  final MailOptionModel mailOptionModel;

  SendIngEmailEvent({required this.mailOptionModel});
}