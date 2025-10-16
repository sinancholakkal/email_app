part of 'spam_bloc.dart';

@immutable
sealed class SpamState {}

final class SpamInitial extends SpamState {}


class InitialLoading extends SpamState{}
class MoreDataLoading extends SpamState{
  bool isLoading;
  List<Email>datas;
  MoreDataLoading({required this.isLoading,required this.datas});
}
class LoadedDataState extends SpamState{
    bool isLoading;
    List<Email>datas;
    LoadedDataState({required this.datas,required this.isLoading});
}
class EmailsErrorState extends SpamState{
  String error;
  EmailsErrorState({required this.error});
}