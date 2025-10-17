import 'dart:async';
import 'dart:developer';

import 'package:email_app/model/email_model.dart';
import 'package:email_app/state/email_bloc/email_bloc.dart';
import 'package:email_app/state/search_bloc/search_bloc.dart';
import 'package:email_app/view/home_screen/widgets/build_emai_card.dart';
import 'package:email_app/view/widgets/dismissible_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  
  List<String> recentSearches = [
    'Meeting',
    'Invoice',
    'Project Update',
    'Newsletter',
  ];

  String selectedFilter = 'All';
  List<String> filters = ['All', 'From', 'Subject', 'Unread', 'Attachments'];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        context.read<SearchBloc>().add(SearchEmailEvent(query: query.trim()));
      }
    });
  }

  void _onRecentSearchTap(String query) {
    _searchController.text = query;
    context.read<SearchBloc>().add(SearchEmailEvent(query: query));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Search
            _buildSearchHeader(theme, isDark),

            // Search Results or Empty State
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return _buildInitialState(isDark);
                  } else if (state is SearchLoadingState) {
                    return _buildLoadingState();
                  } else if (state is SearchLoadedState) {
                    return _buildSearchResults(state.emails, isDark);
                  } else if (state is NoDataFoundState) {
                    return _buildNoResultsState(isDark);
                  } else if (state is SearchErrorState) {
                    return _buildErrorState(state.error, isDark);
                  }
                  return _buildInitialState(isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[400]!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.search,
                size: 64,
                color: Colors.blue[400]!.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try searching with different keywords\nor check your spelling',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                _focusNode.requestFocus();
              },
              icon: const Icon(CupertinoIcons.refresh),
              label: const Text('Clear Search'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[400],
                side: BorderSide(color: Colors.blue[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: theme.appBarTheme.foregroundColor,
                  size: 22,
                ),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),

              // Cupertino Search Field
              Expanded(
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  placeholder: 'Search emails...',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  placeholderStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 16,
                  ),
                  backgroundColor: isDark
                      ? Colors.grey[800]!.withOpacity(0.5)
                      : Colors.grey[100]!,
                  borderRadius: BorderRadius.circular(15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemColor: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    color: isDark ? Colors.grey[500]! : Colors.grey[600]!,
                    size: 20,
                  ),
                  suffixIcon: Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: isDark ? Colors.grey[500]! : Colors.grey[600]!,
                    size: 20,
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      context.read<SearchBloc>().add(
                        SearchEmailEvent(query: query.trim()),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              backgroundColor: isDark 
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.grey[100],
              selectedColor: Colors.blue[400],
              labelStyle: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? Colors.grey[300] : Colors.grey[800]),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected 
                      ? Colors.blue[400]! 
                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }
// 
  Widget _buildInitialState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Tips
          _buildSectionHeader('Search Tips', isDark),
          const SizedBox(height: 16),
          _buildTipCard(
            icon: CupertinoIcons.person_circle,
            title: 'Search by sender',
            description: 'Type sender name or email',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            icon: CupertinoIcons.doc_text,
            title: 'Search by subject',
            description: 'Find emails by subject keywords',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            icon: CupertinoIcons.paperclip,
            title: 'Find attachments',
            description: 'Search for emails with files',
            isDark: isDark,
          ),
          
          const SizedBox(height: 32),
          
         
            
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[400]!.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.blue[400],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue[400]),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Email> emails, bool isDark) {
    return CustomScrollView(
      slivers: [
        // Results count
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              children: [
                Text(
                  '${emails.length} result${emails.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Email list
        SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final email = emails[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: DismissibleWidget(
                    email: email,
                    onDelete: () {
                      log("Delete pressed");
                      context.read<EmailBloc>().add(
                        TrashEmailEvent(messageId: email.id),
                      );
                      context.pop();
                    },
                    child: BuildEmaiCard(
                      starredType: StarredType.fromHome,
                      email: email,
                      index: index,
                      enableAnimation: index < 3,
                    ),
                  ),
                );
              },
              childCount: emails.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[400]!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (_searchController.text.trim().isNotEmpty) {
                  context.read<SearchBloc>().add(
                    SearchEmailEvent(query: _searchController.text.trim()),
                  );
                }
              },
              icon: const Icon(CupertinoIcons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
