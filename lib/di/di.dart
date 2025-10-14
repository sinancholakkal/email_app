import 'package:email_app/model/user_service.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;
Future<void> initializeDependencies() async {
  sl.registerSingleton<UserService>(UserService());
}
