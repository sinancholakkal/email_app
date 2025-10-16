import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:email_app/model/email_model.dart';
import 'package:email_app/service/email_service.dart';
import 'package:meta/meta.dart';

part 'sended_email_event.dart';
part 'sended_email_state.dart';

class SendedEmailBloc extends Bloc<SendedEmailEvent, SendedEmailState> {
  
  SendedEmailBloc() : super(EmailInitial()) {
      final emailService  = EmailService();
  List<Email> emails = [];
  String nextPageToken = "";
    on<LoadSendedDataEvent>((event, emit)async {
       if (nextPageToken.isNotEmpty) {
        emit(MoreDataLoading(datas: emails, isLoading: true));
      } else {
        emit(InitialLoading());
      }
      try {
        final datas = await emailService.fetchInboxEmails(nextPageToken: nextPageToken,label: "SENT");
 
        emails.addAll(datas['emails']);
        nextPageToken = datas['nextPageToken'];
         emit(LoadedDataState(datas: emails, isLoading: false));
      } catch (e) {

        log(e.toString());
        emit(EmailsErrorState(error: "Something went wrong"));
      }
    });
    on<RefreshSendedDataEvent>((event, emit)async {
      emit(InitialLoading());
     emails.clear();
     nextPageToken = "";
     add(LoadSendedDataEvent());
    });
  }
}
