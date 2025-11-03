import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:email_app/model/email_model.dart';
import 'package:email_app/service/email_service.dart';
import 'package:email_app/service/starred_email_service.dart';
import 'package:email_app/service/trash_service.dart';
import 'package:meta/meta.dart';

part 'email_event.dart';
part 'email_state.dart';

class EmailBloc extends Bloc<EmailEvent, EmailState> {
  final emailService = EmailService();
  List<Email> emails = [];
  String? nextPageToken;
  EmailBloc() : super(EmailInitial()) {
    on<LoadDataEvent>((event, emit) async {
      if (nextPageToken!=null) {
        log("Next page token is not empty*********************************");
        emit(MoreDataLoading(datas: emails, isLoading: true));
      } else if(nextPageToken==null) {
        log("next page token is empty*********************************");
        emit(InitialLoading());
      }
      try {
        if(nextPageToken!=""){
          final datas = await emailService.fetchInboxEmails(
          nextPageToken: nextPageToken??"",
        );

        emails.addAll(datas['emails']);
        nextPageToken = datas['nextPageToken'];
       
        log("nextPageToken: $nextPageToken ==============================================================");
        emit(LoadedDataState(datas: emails, isLoading: false));
        }else{
          emit(LoadedDataState(datas: emails, isLoading: false));
        }
      } catch (e) {
        log(e.toString());
        //emit(AllEmailsErrorState(error: e.toString()));
      }
    });
    on<MarkEmailAsReadEvent>((event, emit) async {
      // await EmailService().markEmailAsRead(event.emailId);
      final nEmails = List<Email>.from(emails);
      log(emails[event.emailIndex].isUnread.toString());
      log("===================================");
      emails.clear();

   
        nEmails[event.emailIndex] = nEmails[event.emailIndex].copyWith(
          isUnread: false,
        );
        await EmailService().markEmailAsRead(event.emailId);
        log("Marked as read");
        emails.addAll(nEmails);
        log(emails[event.emailIndex].isUnread.toString());
        log("Emitting new state");
        emit(LoadedDataState(datas: emails, isLoading: false));
      
    });
    on<RefreshDataEvent>((event, emit) async {
      emit(InitialLoading());
      emails.clear();
      nextPageToken =null;
      add(LoadDataEvent());
    });

    on<IstarrEventHome>((event, emit) async {
      await StarredEmailService().toggleStarStatus(
        event.messageId,
        event.shouldStar,
      );

      // Update local state
      final emailIndex = emails.indexWhere((e) => e.id == event.messageId);
      if (emailIndex != -1) {
        emails[emailIndex] = emails[emailIndex].copyWith(
          isStarred: event.shouldStar,
        );
        emit(LoadedDataState(datas: emails, isLoading: false));
      }
    });
    on<TrashEmailEvent>((event, emit) async {
      await TrashService().trashEmail(event.messageId);
      emails.removeWhere((element) => element.id == event.messageId);
      emit(LoadedDataState(datas: emails, isLoading: false));
    });
  }
}
