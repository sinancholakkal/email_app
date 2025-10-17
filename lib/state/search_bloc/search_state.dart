part of 'search_bloc.dart';

@immutable
sealed class SearchState {}

final class SearchInitial extends SearchState {}
final class SearchLoadingState extends SearchState {}
final class SearchLoadedState extends SearchState {
  final List<Email> emails;
  SearchLoadedState({required this.emails});
}
final class SearchErrorState extends SearchState {
  final String error;
  SearchErrorState({required this.error});
}
class NoDataFoundState extends SearchState {}