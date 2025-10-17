import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:email_app/model/email_model.dart';
import 'package:email_app/service/email_service.dart';
import 'package:meta/meta.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchEmailEvent>((event, emit) async{
      emit(SearchLoadingState());
      try{
        final emails = await EmailService().fetchInboxEmails(query: event.query);
        
        log("Emails: ${emails['emails']}");
        if(emails['emails'].isEmpty){
          log("No data found");
          emit(NoDataFoundState());
        }else{
          log("Data found");
          emit(SearchLoadedState(emails: emails['emails']));
        }
      }catch(e){
        emit(SearchErrorState(error: "Somthing went wrong"));
      }
    });
  }
}
