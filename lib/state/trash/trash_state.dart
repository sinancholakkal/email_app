part of 'trash_bloc.dart';

@immutable
sealed class TrashState {}

final class TrashInitial extends TrashState {}
class InitialLoading extends TrashState{}
class MoreDataLoading extends TrashState{
  bool isLoading;
  List<Email>datas;
  MoreDataLoading({required this.isLoading,required this.datas});
}
class LoadedDataState extends TrashState{
    bool isLoading;
    List<Email>datas;
    LoadedDataState({required this.datas,required this.isLoading});
}
class EmailsErrorState extends TrashState{
  String error;
  EmailsErrorState({required this.error});
}