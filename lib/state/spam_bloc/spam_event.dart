part of 'spam_bloc.dart';

@immutable
sealed class SpamEvent {}
class LoadSpamDataEvent extends SpamEvent{}
class RefreshSpamDataEvent extends SpamEvent{}
class SpamDisposeEvent extends SpamEvent{}
class ToggleStarEventSpam extends SpamEvent{
  final String messageId;
  final bool shouldSpam;
  ToggleStarEventSpam({required this.messageId, required this.shouldSpam});
}
class TrashEmailEventSpam extends SpamEvent{
  final String messageId;
  TrashEmailEventSpam({required this.messageId});
}