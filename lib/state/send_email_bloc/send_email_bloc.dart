import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:email_app/model/email_oprion_model.dart';
import 'package:email_app/service/send_email_service.dart';
import 'package:meta/meta.dart';

part 'send_email_event.dart';
part 'send_email_state.dart';

class SendEmailBloc extends Bloc<SendEmailEvent, SendEmailState> {
  final SendEmailService sendEmailService = SendEmailService();
  SendEmailBloc() : super(SendEmailInitial()) {
    on<SendIngEmailEvent>((event, emit) async{
      emit(SendEmailLoadingState());
      try{
        final response = await sendEmailService.sendEmail(event.mailOptionModel);
        
        log(response.toString());
        emit(SendEmailSuccessState());
      }catch(e){
        emit(SendEmailErrorState(error: e.toString()));
      }
    });
  }
}
