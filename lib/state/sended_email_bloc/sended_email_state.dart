part of 'sended_email_bloc.dart';

@immutable
sealed class SendedEmailState {}

final class EmailInitial extends SendedEmailState {}

//All email states
class InitialLoading extends SendedEmailState{}
class MoreDataLoading extends SendedEmailState{
  bool isLoading;
  List<Email>datas;
  MoreDataLoading({required this.isLoading,required this.datas});
}
class LoadedDataState extends SendedEmailState{
    bool isLoading;
    List<Email>datas;
    LoadedDataState({required this.datas,required this.isLoading});
}
class EmailsErrorState extends SendedEmailState{
  String error;
  EmailsErrorState({required this.error});
}