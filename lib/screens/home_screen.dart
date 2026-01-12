import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/chat_screen.dart';
import 'package:we_chat/screens/profile_screen.dart';
import 'package:we_chat/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  List<Chatuser> _users = [];
  List<Chatuser> _searchList = [];


  @override
  Widget build(BuildContext context) {
    print('CURRENT USER UID: ${Api.currentUser.uid}');
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search',
                ),
                onChanged: (val) {
                  _searchList = _users
                      .where((u) =>
                          u.displayName
                              .toLowerCase()
                              .contains(val.toLowerCase()) ||
                          u.email
                              .toLowerCase()
                              .contains(val.toLowerCase()))
                      .toList();
                  setState(() {});
                },
              )
            : const Text('We Chat'),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching
                  ? CupertinoIcons.clear_circled_solid
                  : Icons.search,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchList.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(user: Api.me),
                ),
              );
            },
          ),
        ],
      ),

      /// ✅ USER-BASED CHAT LIST (STABLE)
      /// 
      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('chats')
      .where('users', arrayContains: Api.currentUser.uid)
      
      .snapshots(),
  builder: (context, chatSnap) {
    if (!chatSnap.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final chatDocs = chatSnap.data!.docs;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allUsers = userSnap.data!.docs
            .map((e) => Chatuser.fromJson(e.data() as Map<String, dynamic>))
            
            .toList();

        return _buildHybridList(chatDocs, allUsers);
      },
    );
  },
),


    );
  }Widget _buildHybridList(
  List<QueryDocumentSnapshot> chatDocs,
  List<Chatuser> allUsers,
) {
  final chattedUserIds = chatDocs
      .map((doc) => List<String>.from(doc['users']))
      .expand((e) => e)
      .where((id) => id != Api.currentUser.uid)
      .toSet();

  final chattedUsers = <Chatuser>[];
  final newUsers = <Chatuser>[];

  for (final user in allUsers) {
    if (chattedUserIds.contains(user.uid)) {
      chattedUsers.add(user);
    } else {
      newUsers.add(user);
    }
  }

  return ListView(
    children: [
      // 🔥 CHATS FIRST
      ...chatDocs.map((chatDoc) {
        final users = List<String>.from(chatDoc['users']);
        final otherUserId =
            users.firstWhere((id) => id != Api.currentUser.uid);

        final user = chattedUsers.firstWhere(
          (u) => u.uid == otherUserId,
          orElse: () =>
              allUsers.firstWhere((u) => u.uid == otherUserId),
        );

        final hasUnread =
            chatDoc['lastSenderId'] != Api.currentUser.uid;

        return ChatUserCard(
          user: user,
          hasUnread: hasUnread,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(user: user),
              ),
            );
          },
        );
      }),

      
      // 👤 USERS WITH NO CHAT YET
      ...newUsers.map((user) {
        return ChatUserCard(
          user: user,
          hasUnread: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(user: user),
              ),
            );
          },
        );
      }),
    ],
  );
}



}
