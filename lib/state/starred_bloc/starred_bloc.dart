import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:email_app/model/email_model.dart';
import 'package:email_app/service/email_service.dart';
import 'package:email_app/service/starred_email_service.dart';
import 'package:email_app/service/trash_service.dart';
import 'package:meta/meta.dart';

part 'starred_event.dart';
part 'starred_state.dart';

class StarredBloc extends Bloc<StarredEvent, StarredState> {
  StarredBloc() : super(StarredInitial()) {
    
    final emailService = EmailService();
    List<Email> emails = [];
    String nextPageToken = "";
    bool isEndReached = false;
    on<LoadStarredDataEvent>((event, emit) async{
      if (nextPageToken.isNotEmpty) {
        emit(MoreDataLoading(datas: emails, isLoading: true));
      }else if (isEndReached==true){
        emit(LoadedDataState(datas: emails, isLoading: false));
      }
      
       else {
        emit(InitialLoading());
      }
      try {
        
       if(isEndReached==false){
         final datas = await emailService.fetchInboxEmails(nextPageToken: nextPageToken,label: "STARRED");
 
        emails.addAll(datas['emails']);
        nextPageToken = datas['nextPageToken'];
        log(nextPageToken);
        if (datas['nextPageToken'] == "") {
          isEndReached = true;
        }
         emit(LoadedDataState(datas: emails, isLoading: false));
       }
      } catch (e) {

        log(e.toString());
        emit(EmailsErrorState(error: "Something went wrong"));
      }
    });
    on<MarkEmailAsReadStarredEvent>((event, emit) async {
      await EmailService().markEmailAsRead(event.emailId);
      final nEmails = List<Email>.from(emails);
      emails.clear();
      nEmails[event.emailIndex] = nEmails[event.emailIndex].copyWith(isUnread: false);
      emails.addAll(nEmails); 
      emit(LoadedDataState(datas: emails, isLoading: false));
    });
    on<RefreshStarredDataEvent>((event, emit)async {
      emit(InitialLoading());
     emails.clear();
     nextPageToken = "";
     isEndReached = false;
     log("RefreshStarredDataEvent");
     add(LoadStarredDataEvent());
    });
    on<StarredDisposeEvent>((event, emit) {
      emails.clear();
      nextPageToken = "";
      isEndReached = false;
    });
    on<ToggleStarEvent>((event, emit) async {
      await StarredEmailService().toggleStarStatus(event.messageId, event.shouldStar);
      log("Toogle star event changed");
      emails.removeWhere((element) => element.id == event.messageId);
      emit(LoadedDataState(datas: emails, isLoading: false));
    });
    on<TrashEmailEventStarred>((event, emit) async {
      await TrashService().trashEmail(event.messageId);
      emails.removeWhere((element) => element.id == event.messageId);
      emit(LoadedDataState(datas: emails, isLoading: false));
    });
  }
}

