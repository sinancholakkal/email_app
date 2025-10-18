import 'package:bloc/bloc.dart';
import 'package:email_app/model/email_model.dart';
import 'package:email_app/service/email_service.dart';
import 'package:email_app/service/starred_email_service.dart';
import 'package:email_app/service/token_service.dart';
import 'package:meta/meta.dart';

part 'email_details_event.dart';
part 'email_details_state.dart';

class EmailDetailsBloc extends Bloc<EmailDetailsEvent, EmailDetailsState> {
  EmailDetailsBloc() : super(EmailDetailsInitial()) {
    on<FetchEmailDetailsEvent>(_onFetchEmailDetails);
    on<IstarrEventEmailDetails>(_onToggleStar);
  }

  Future<void> _onFetchEmailDetails(
    FetchEmailDetailsEvent event,
    Emitter<EmailDetailsState> emit,
  ) async {
    emit(EmailDetailsLoading());
    try {
      final accessToken = await TokenService().getAccessToken();
      if (accessToken == null) {
        emit(EmailDetailsError(message: 'Authentication required'));
        return;
      }

      final email = await EmailService().fetchEmailDetails(accessToken, event.emailId);
      
      if (email != null) {
        await EmailService().markEmailAsRead(event.emailId);
        emit(EmailDetailsLoaded(email: email));
      } else {
        emit(EmailDetailsError(message: 'Failed to fetch email'));
      }
    } catch (e) {
      emit(EmailDetailsError(message: 'Error: ${e.toString()}'));
    }
  }

  Future<void> _onToggleStar(
    IstarrEventEmailDetails event,
    Emitter<EmailDetailsState> emit,
  ) async {
    await StarredEmailService().toggleStarStatus(event.messageId, event.shouldStar);
  }
}
