part of 'starred_bloc.dart';

@immutable
sealed class StarredEvent {}
class LoadStarredDataEvent extends StarredEvent{}
class RefreshStarredDataEvent extends StarredEvent{}
class StarredDisposeEvent extends StarredEvent{}
class ToggleStarEvent extends StarredEvent{
  final String messageId;
  final bool shouldStar;
  ToggleStarEvent({required this.messageId, required this.shouldStar});
}
class TrashEmailEventStarred extends StarredEvent{
  final String messageId;
  TrashEmailEventStarred({required this.messageId});
}