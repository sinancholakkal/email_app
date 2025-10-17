import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:email_app/model/email_model.dart';
import 'package:email_app/service/email_service.dart';
import 'package:email_app/service/starred_email_service.dart';
import 'package:email_app/service/trash_service.dart';
import 'package:meta/meta.dart';

part 'spam_event.dart';
part 'spam_state.dart';

class SpamBloc extends Bloc<SpamEvent, SpamState> {
  SpamBloc() : super(SpamInitial()) {
    final emailService = EmailService();
    List<Email> emails = [];
    String nextPageToken = "";
    bool isEndReached = false;
    on<LoadSpamDataEvent>((event, emit) async{
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
         final datas = await emailService.fetchInboxEmails(nextPageToken: nextPageToken,label: "SPAM");
 
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
    on<RefreshSpamDataEvent>((event, emit)async {
      emit(InitialLoading());
     emails.clear();
     nextPageToken = "";
     isEndReached = false;
     log("RefreshStarredDataEvent");
     add(LoadSpamDataEvent());
    });
    // on<StarredDisposeEvent>((event, emit) {
    //   emails.clear();
    //   nextPageToken = "";
    //   isEndReached = false;
    // });
    on<ToggleStarEventSpam>((event, emit) async {
      await StarredEmailService().toggleStarStatus(event.messageId, event.shouldSpam);
      log("Toogle star event changed");
    });
    on<TrashEmailEventSpam>((event, emit) async {
      await TrashService().trashEmail(event.messageId);
      emails.removeWhere((element) => element.id == event.messageId);
      emit(LoadedDataState(datas: emails, isLoading: false));
    });
  }
}

