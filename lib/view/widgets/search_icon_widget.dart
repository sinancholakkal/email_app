import 'package:email_app/state/search_bloc/search_bloc.dart';
import 'package:email_app/view/search_screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchIconWidget extends StatelessWidget {
  const SearchIconWidget({super.key, required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search, color: theme.appBarTheme.foregroundColor),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => SearchBloc(), 
              child: SearchScreen(),
            ),
          ),
        );
      },
    );
  }
}
