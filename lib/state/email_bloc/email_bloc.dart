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
  String nextPageToken = "";
  EmailBloc() : super(EmailInitial()) {
    on<LoadDataEvent>((event, emit) async {
      if (nextPageToken.isNotEmpty) {
        emit(MoreDataLoading(datas: emails, isLoading: true));
      } else {
        emit(InitialLoading());
      }
      try {
        final datas = await emailService.fetchInboxEmails(
          nextPageToken: nextPageToken,
        );

        emails.addAll(datas['emails']);
        nextPageToken = datas['nextPageToken'];
        emit(LoadedDataState(datas: emails, isLoading: false));
      } catch (e) {
        log(e.toString());
        //emit(AllEmailsErrorState(error: e.toString()));
      }
    });
    on<RefreshDataEvent>((event, emit) async {
      emit(InitialLoading());
      emails.clear();
      nextPageToken = "";
      add(LoadDataEvent());
    });

    on<IstarrEventHome>((event, emit) async {
      await StarredEmailService().toggleStarStatus(event.messageId, event.shouldStar);
    });
    on<TrashEmailEvent>((event, emit) async {
      await TrashService().trashEmail(event.messageId);
      emails.removeWhere((element) => element.id == event.messageId);
      emit(LoadedDataState(datas: emails, isLoading: false));
    });
  }
}
