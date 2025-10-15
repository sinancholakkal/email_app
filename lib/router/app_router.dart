import 'package:email_app/model/email_model.dart';
import 'package:email_app/view/email_detail_screen/email_detail_screen.dart';
import 'package:email_app/view/home_screen/home_screen.dart';
import 'package:email_app/view/login_screen/login_screen.dart';
import 'package:email_app/view/splash_screen/splash_screen.dart';
import 'package:email_app/view/tab/tabs.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/tabs', builder: (context, state) => Tabs()),
    GoRoute(
      path: '/email_detail',
      builder: (context, state) =>
          EmailDetailScreen(email: state.extra as Email,),
    ),

    // GoRoute(
    //   path: '/profile/:userId', // The ':userId' is the parameter
    //   builder: (context, state) {
    //     // Extract the userId from the route's state
    //     final index = state.pathParameters['userId']!;
    //     return OtherProfileDetailsScreen(index: int.parse(index));
    //   },
    // ),
    // GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    // GoRoute(
    //   path: '/register',
    //   builder: (context, state) => const RegisterScreen(),
    // ),
    // GoRoute(path: "/home", builder: (context, state) =>  HomeScreen()),
    //  GoRoute(path: "/splash", builder: (context, state) =>  ScreenSplash()),
    //  GoRoute(path: '/viewItem', builder: (context, state) {
    //   final passWordModel = state.extra as PasswordModel;
    //   return ViewScreen(passwordModel: passWordModel,);
    //  }),
    //  GoRoute(path: '/addedit', builder: (context, state) {
    //   final Map<String,dynamic> params = state.extra as Map<String,dynamic>;

    //   return AddEditItemScreen(type: params['type'],passwordModel: params['model'],);
    //  }),
    //  GoRoute(path: '/forgot', builder: (context, state) => const ForgotScreen()),
    //  GoRoute(path: '/search', builder: (context, state) {
    //   final params = state.extra as List<PasswordModel>;

    //   return SearchScreen(models: params,);
    //  }),
  ],
);
