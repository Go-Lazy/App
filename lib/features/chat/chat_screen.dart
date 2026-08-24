import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Placeholder Chat destination. Reachable from the home bottom navigation.
/// Realtime chat/backend integration lands in a later phase.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primarySurface,
              child: Icon(
                Icons.chat_bubble_outline,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Chat is coming soon',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Message owners and renters directly from here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
