part of 'email_bloc.dart';

@immutable
sealed class EmailEvent {}
class LoadDataEvent extends EmailEvent{}