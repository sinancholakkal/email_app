import 'package:email_app/di/di.dart';
import 'package:email_app/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _checkAuth();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  Future<void> _checkAuth()async{
    await Future.delayed(const Duration(seconds: 2));
    final userUid = await AuthService().getCurrentUserUid();
    if(userUid!=null){
      context.go('/tabs');
    }else{
      context.go('/login');
    }
  }
}