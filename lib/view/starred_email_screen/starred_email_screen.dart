import 'dart:developer';

import 'package:email_app/model/email_model.dart';
import 'package:email_app/state/starred_bloc/starred_bloc.dart';
import 'package:email_app/view/home_screen/widgets/build_emai_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StarredEmailScreen extends StatefulWidget {
  const StarredEmailScreen({super.key});

  @override
  State<StarredEmailScreen> createState() => _SendEmailScreenState();
}

class _SendEmailScreenState extends State<StarredEmailScreen> {
  late ScrollController _controller;
  late StarredBloc _starredBloc;
  bool isLoading = false;
  List<Email> datas = [];
  
  @override
  void initState() {
    super.initState();
    _starredBloc = context.read<StarredBloc>();
    _starredBloc.add(LoadStarredDataEvent());
    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.position.maxScrollExtent * 0.9 <=
              _controller.position.pixels &&
          !isLoading) {
        log("Loading more data");
        _starredBloc.add(LoadStarredDataEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          return true;
        } else {
          context.go('/tabs');
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.appBarTheme.backgroundColor,
          
          title: Text(
            'Starred',
            style: TextStyle(
              color: theme.appBarTheme.foregroundColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            BlocBuilder<StarredBloc, StarredState>(
              builder: (context, state) {
                int emailCount = 0;
                if (state is LoadedDataState) {
                  emailCount = state.datas.length;
                }
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green[400],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$emailCount',
                        style: TextStyle(
                          color: Colors.green[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: theme.appBarTheme.foregroundColor,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search feature coming soon')),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _starredBloc.add(RefreshStarredDataEvent());
          },
          child: BlocConsumer<StarredBloc, StarredState>(
            builder: (context, state) {
              if (state is InitialLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.green[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Loading Starred emails...',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                itemCount: datas.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == datas.length) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue[400],
                        ),
                      ),
                    );
                  }

                  final email = datas[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: BuildEmaiCard(
                      starredType: StarredType.fromStar,
                      email: email,
                      index: index,
                      enableAnimation: index < 5,
                    ),
                  );
                },
              );
            },
            listener: (context, state) {
              if (state is MoreDataLoading) {
                isLoading = state.isLoading;
              } else if (state is LoadedDataState) {
                isLoading = state.isLoading;
                datas = state.datas;
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    _starredBloc.add(StarredDisposeEvent());
    super.dispose();
  }
}
