import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String _policyMdContent = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolicyContent();
  }

  Future<void> _loadPolicyContent() async {
    try {
      final content = await rootBundle.loadString('assets/privacy_policy.md');
      if (mounted) {
        setState(() {
          _policyMdContent = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Log the error for debugging
      print("Error loading privacy policy from assets: $e");
      if (mounted) {
        setState(() {
          _policyMdContent = 'Failed to load Privacy Policy. Please try again later or contact support.';
          _isLoading = false;
        });
      }
    }
  }

  // Helper function to launch URLs (requires url_launcher package)
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching URL $url: $e');
      // Optionally show a user-friendly error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text("Qmail Privacy Policy"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _policyMdContent.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Error: Privacy Policy content is empty or failed to load."),
                  ),
                )
              : SingleChildScrollView( // Use SingleChildScrollView for web
                  padding: const EdgeInsets.all(24.0), // More padding for web
                  child: MarkdownBody(
                    data: _policyMdContent,
                    selectable: true, // Allow users to select and copy text
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      h2: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 22, 
                        fontWeight: FontWeight.w600, 
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16.0, 
                        height: 1.6, 
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87),
                      ),
                      a: TextStyle(
                        color: Theme.of(context).colorScheme.primary, 
                        decoration: TextDecoration.underline,
                      ),
                      listBullet: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16.0, 
                        height: 1.6, 
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87),
                      ),
                    ),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        _launchURL(href);
                      }
                    },
                  ),
                ),
    );
  }
}