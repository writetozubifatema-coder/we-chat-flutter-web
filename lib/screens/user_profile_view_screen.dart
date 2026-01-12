import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/api/api.dart';

class UserProfileViewScreen extends StatelessWidget {
  final Chatuser user;

  const UserProfileViewScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isBlocked = false; // we’ll wire this next

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // 🔹 PROFILE IMAGE (BIG)
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: user.photoURL.isNotEmpty
                  ? CachedNetworkImageProvider(user.photoURL)
                  : null,
              child: user.photoURL.isEmpty
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),

            const SizedBox(height: 16),

            // 🔹 NAME
            Text(
              user.displayName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // 🔹 EMAIL
            Text(
              user.email,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 🔹 ABOUT
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: Text(user.about.isNotEmpty
                  ? user.about
                  : 'Hey there! I am using We Chat'),
            ),

            // 🔹 PHONE
            if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(user.phoneNumber!),
              ),

            const SizedBox(height: 30),

            // 🔴 BLOCK / UNBLOCK BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked ? Colors.green : Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                // we’ll connect logic next
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isBlocked ? 'User unblocked' : 'User blocked',
                    ),
                  ),
                );
              },
              child: Text(isBlocked ? 'Unblock User' : 'Block User'),
            ),
          ],
        ),
      ),
    );
  }
}
