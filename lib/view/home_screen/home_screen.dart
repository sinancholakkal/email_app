import 'dart:developer';

import 'package:email_app/model/email_model.dart';
import 'package:email_app/service/email_service.dart';
import 'package:email_app/state/auth_bloc/auth_bloc.dart';
import 'package:email_app/state/email_bloc/email_bloc.dart';
import 'package:email_app/view/home_screen/widgets/build_emai_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _controller;
  bool isLoading = false;
  List<Email> datas = [];
  int pageCount = 10;
  @override
  void initState() {
    //EmailService().fetchInboxEmails();
    context.read<EmailBloc>().add(LoadDataEvent());
    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.position.maxScrollExtent * 0.9 <=
              _controller.position.pixels &&
          !isLoading) {
        log("Loading more data");
        context.read<EmailBloc>().add(LoadDataEvent());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is GoogleSignOutSuccess) {
          context.go("/login");
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: Text(
            'Inbox',
            style: TextStyle(
              color: theme.appBarTheme.foregroundColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            BlocBuilder<EmailBloc, EmailState>(
              builder: (context, state) {
                int emailCount = 0;
                if (state is LoadedDataState) {
                  emailCount = state.datas.length;
                }
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$emailCount',
                      style: TextStyle(
                        color: Colors.blue[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                // Search functionality
              },
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                color: theme.appBarTheme.foregroundColor,
              ),
              onPressed: () {
                context.read<AuthBloc>().add(GoogleSignOutEvent());
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<EmailBloc>().add(RefreshDataEvent());
          },
          child: _buildEmailList(),
        ),
      ),
    );
  }

  Widget _buildEmailList() {
    return BlocConsumer<EmailBloc, EmailState>(
      listener: (context, state) {
        if (state is MoreDataLoading) {
          isLoading = state.isLoading;
        } else if (state is LoadedDataState) {
          isLoading = state.isLoading;
          datas = state.datas;
        }
      },
      builder: (context, state) {
        if (state is InitialLoading) {
          return Center(child: CircularProgressIndicator());
        }

        // if (state is AllEmailsLoadedState) {
        //   if (state.emails.isEmpty) {
        //     return Center(
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Icon(Icons.inbox, size: 64, color: Colors.grey[600]),
        //           const SizedBox(height: 16),
        //           Text(
        //             'No emails',
        //             style: TextStyle(
        //               fontSize: 18,
        //               color: Colors.grey[400],
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),
        //           const SizedBox(height: 8),
        //           Text(
        //             'Your inbox is empty',
        //             style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        //           ),
        //         ],
        //       ),
        //     );
        //   }

        return ListView.builder(
          controller: _controller,
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: datas.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at bottom
            if (index == datas.length) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blue[400]),
                ),
              );
            }

            final email = datas[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              // Only animate first 5 items for better performance
              child: BuildEmaiCard(
                email: email,
                index: index,
                enableAnimation: index < 5, // Only animate first 5 items
              ),
            );
          },
        );
      },

      // if (state is AllEmailsErrorState) {
      //   return Center(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
      //         const SizedBox(height: 16),
      //         Text(
      //           'Error loading emails',
      //           style: TextStyle(
      //             fontSize: 18,
      //             color: Colors.grey[400],
      //             fontWeight: FontWeight.w500,
      //           ),
      //         ),
      //         const SizedBox(height: 8),
      //         Text(
      //           state.error,
      //           style: TextStyle(fontSize: 14, color: Colors.grey[500]),
      //           textAlign: TextAlign.center,
      //         ),
      //         const SizedBox(height: 24),
      //         ElevatedButton.icon(
      //           onPressed: () {
      //             context.read<EmailBloc>().add(FetchAllEmailsEvent());
      //           },
      //           icon: const Icon(Icons.refresh),
      //           label: const Text('Retry'),
      //         ),
      //       ],
      //     ),
      //   );
      // }

      // Default empty state
      //return Container();
    );
  }
}
