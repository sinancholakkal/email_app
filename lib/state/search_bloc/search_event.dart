part of 'search_bloc.dart';

@immutable
sealed class SearchEvent {}
class SearchEmailEvent extends SearchEvent{
  final String query;
  SearchEmailEvent({required this.query});
}