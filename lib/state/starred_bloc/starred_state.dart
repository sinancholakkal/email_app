part of 'starred_bloc.dart';

@immutable
sealed class StarredState {}

final class StarredInitial extends StarredState {}


//All email states
class InitialLoading extends StarredState{}
class MoreDataLoading extends StarredState{
  bool isLoading;
  List<Email>datas;
  MoreDataLoading({required this.isLoading,required this.datas});
}
class LoadedDataState extends StarredState{
    bool isLoading;
    List<Email>datas;
    LoadedDataState({required this.datas,required this.isLoading});
}
class EmailsErrorState extends StarredState{
  String error;
  EmailsErrorState({required this.error});
}