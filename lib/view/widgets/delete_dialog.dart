import 'package:flutter/material.dart';

Future<bool?> deleteDialog(BuildContext context, VoidCallback onDelete) {
    return showDialog(
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
  }