import 'package:flutter/material.dart';

/// Global application color palette.
/// Use these constants across the app to keep colors consistent.
class AppColors {
	AppColors._();

	static const Color background = Color(0xFFFFFFFF); // white
	static const Color primary = Color(0xFF4285F4); // blue (default/google blue)
	static const Color googleBlue = Color(0xFF4285F4);
	static const Color onPrimary = Color(0xFFFFFFFF); // white text on primary
	static const Color textPrimary = Color(0xDD000000); // approx. Colors.black87
	static const Color textSecondary = Color(0xFF757575); // approx. Colors.grey[600]

    static Color getEmailAvatarColor(String email) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[email.hashCode % colors.length];
  }
}


