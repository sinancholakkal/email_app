import 'package:bloc/bloc.dart';
import 'package:email_app/di/di.dart';
import 'package:email_app/service/auth_service.dart';
import 'package:email_app/service/token_service.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final authService = AuthService();
  final tokenService = TokenService();
  AuthBloc() : super(AuthInitial()) {
    on<GoogleSignInEvent>((event, emit)async{
      emit(GoogleSignInLoading());
      try{
        final user = await authService.signInWithGoogle();
        if(user!=null){
          emit(GoogleSignInSuccess());
        }else{
          emit(GoogleSignInFailure(error: 'User not found'));
        }
      }catch(e){
        emit(GoogleSignInFailure(error: 'Error signing in with Google'));
      }
    });
    on<GoogleSignOutEvent>((event, emit)async{
      emit(GoogleSignOutLoading());
      try{
        await authService.signOut();
        await tokenService.deleteAccessToken();
        emit(GoogleSignOutSuccess());
      }catch(e){
        emit(GoogleSignOutFailure(error: 'Error signing out with Google'));
      }
    });
  }
}
