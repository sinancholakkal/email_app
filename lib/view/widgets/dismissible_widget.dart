
import 'package:email_app/model/email_model.dart';
import 'package:flutter/material.dart';

class DismissibleWidget extends StatelessWidget {
  const DismissibleWidget({
    super.key,
    required this.email,
    required this.onDelete,
    required this.child,
  });
  final VoidCallback onDelete;
  final Email email;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(email.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        // Optional: Show confirmation dialog
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text(
                'Are you sure you want to delete this email?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(onPressed: onDelete, child: const Text('Delete')),
              ],
            );
          },
        );
      },
      child: child,
    );
  }
}
