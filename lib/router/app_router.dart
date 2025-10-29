import 'package:email_app/view/email_detail_screen/email_detail_screen.dart';
import 'package:email_app/view/home_screen/home_screen.dart';
import 'package:email_app/view/login_screen/login_screen.dart';
import 'package:email_app/view/privacy_policy_screen/privacy_policy_screen.dart';
import 'package:email_app/view/send_email_screen/send_email_screem.dart';
import 'package:email_app/view/splash_screen/splash_screen.dart';
import 'package:email_app/view/starred_email_screen/starred_email_screen.dart';
import 'package:email_app/view/tab/tabs.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/tabs', builder: (context, state) => Tabs()),
    // GoRoute(
    //   path: '/email_detail',
    //   builder: (context, state) =>
    //       EmailDetailScreen(emailId: state.extra as String,),
    // ),
    GoRoute(path: '/starred', builder: (context, state) => StarredEmailScreen()),
    GoRoute(path: '/send_email', builder: (context, state) => SendEmailScreen()),
    GoRoute(path: '/privacy_policy', builder: (context, state) => PrivacyPolicyPage()),
  ],
);
