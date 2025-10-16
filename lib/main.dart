import 'package:email_app/constants/app_theme.dart';
import 'package:email_app/firebase_options.dart';
import 'package:email_app/router/app_router.dart';
import 'package:email_app/state/auth_bloc/auth_bloc.dart';
import 'package:email_app/state/starred_bloc/starred_bloc.dart';
import 'package:email_app/state/email_bloc/email_bloc.dart';
import 'package:email_app/state/send_email_bloc/send_email_bloc.dart';
import 'package:email_app/state/sended_email_bloc/sended_email_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main()async {
  
  WidgetsFlutterBinding.ensureInitialized();
   // await initializeDependencies();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => EmailBloc(),
        ),
        BlocProvider(
          create: (context) => SendEmailBloc(),
        ),
        BlocProvider(
          create: (context) => SendedEmailBloc(),
        ),
        BlocProvider(
          create: (context) => StarredBloc(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Email App',
        themeMode: ThemeMode.dark, 
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
      )
    );
  }
}

