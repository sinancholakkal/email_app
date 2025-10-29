part of 'email_bloc.dart';

@immutable
sealed class EmailState {}

final class EmailInitial extends EmailState {}

//All email states
class InitialLoading extends EmailState{}
class MoreDataLoading extends EmailState{
  bool isLoading;
  List<Email>datas;
  MoreDataLoading({required this.isLoading,required this.datas});
}
class LoadedDataState extends EmailState{
    bool isLoading;
    List<Email>datas;
    LoadedDataState({required this.datas,required this.isLoading});
}
class AllEmailsErrorState extends EmailState{
  final String error;

  AllEmailsErrorState({required this.error});
  
}