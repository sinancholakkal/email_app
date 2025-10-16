part of 'trash_bloc.dart';

@immutable
sealed class TrashEvent {}
class LoadTrashDataEvent extends TrashEvent{}
class RefreshTrashDataEvent extends TrashEvent{}
class ToggleTrashStarEvent extends TrashEvent{
  final String messageId;
  final bool shouldTrash;
  ToggleTrashStarEvent({required this.messageId, required this.shouldTrash});
}