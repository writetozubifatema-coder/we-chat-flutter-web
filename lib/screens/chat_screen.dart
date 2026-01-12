import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:we_chat/api/api.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/screens/user_profile_view_screen.dart';

class ChatScreen extends StatefulWidget {
  final Chatuser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  bool _showEmoji = false;

 @override
void initState() {
  super.initState();
  Api.isChatScreenOpen = true;
  clearUnreadFlag();
  markAllMessagesAsRead();
}

  @override
  void dispose() {
    Api.isChatScreenOpen = false;
    super.dispose();
  }

  Future<void> clearUnreadFlag() async {
  final user = Api.auth.currentUser;
  if (user == null) return;

  Future<void> clearUnreadFlag() async {
  final convoId = Api.getConversationID(widget.user.uid);

  await FirebaseFirestore.instance
      .collection('chats')
      .doc(convoId)
      .update({
    'lastSenderId': widget.user.uid,
  });
}



}



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        body: Column(
          children: [
            // ================= MESSAGES =================
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: Api.getAllMessages(widget.user),
                builder: (context, snapshot) {
                 if (!snapshot.hasData) {
  return const Center(child: CircularProgressIndicator());
}

if (snapshot.data!.docs.isEmpty) {
  return const Center(
    child: Text('Say Hi 👋', style: TextStyle(fontSize: 20)),
  );
}


                  final messages = snapshot.data!.docs
                      .map((doc) => Message.fromJson(doc.data(), doc.id))
                      .toList();

                  return ListView.builder(
                    padding: EdgeInsets.only(top: mq.height * .01),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      // STEP 4: mark message as read
                      Future<void> markAllMessagesAsRead() async {
                        final snapshot = await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(Api.getConversationID(widget.user.uid))
                            .collection('messages')
                            .where('toId', isEqualTo: Api.currentUser.uid)
                            .where('read', isEqualTo: 0)
                            .get();

                        for (final doc in snapshot.docs) {
                          doc.reference.update({
                            'read': DateTime.now().millisecondsSinceEpoch,
                          });
                        }
                      }

                      final isMe = msg.fromId == Api.currentUser.uid;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          constraints: BoxConstraints(maxWidth: mq.width * .7),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.green.shade200
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // ✅ MESSAGE TEXT
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  12,
                                  8,
                                  isMe
                                      ? 72
                                      : 12, // ⭐ reserve space for time + tick
                                  isMe ? 22 : 8, // ⭐ reserve space at bottom
                                ),
                                child: msg.type == Type.text
                                    ? Text(
                                        msg.msg,
                                        style: const TextStyle(fontSize: 16),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          msg.msg, // 🔥 Firebase Storage URL
                                          width: 200,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, progress) {
                                                if (progress == null)
                                                  return child;
                                                return const Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 80,
                                              ),
                                        ),
                                      ),
                              ),

                              // ✅ TIME + TICK (ONLY FOR SENDER)
                              if (isMe)
                                Positioned(
                                  bottom: 4,
                                  right: 6,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(context, msg.sent),

                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.done_all,
                                        size: 16,
                                        color: msg.read == 0
                                            ? Colors.grey
                                            : Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ================= INPUT =================

            // ================= EMOJI PICKER =================
            _chatInput(),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _showEmoji ? 260 : 0,
              child: EmojiPicker(
                textEditingController: _messageController,
                config: Config(
                  columns: 8,
                  emojiSizeMax: 28, // important for web
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  gridPadding: EdgeInsets.zero,

                  bgColor: const Color(0xFFF2F2F2),
                  indicatorColor: Colors.green,
                  iconColor: Colors.grey,
                  iconColorSelected: Colors.green,
                  backspaceColor: Colors.green,

                  enableSkinTones: true,
                  skinToneIndicatorColor: Colors.green,

                  // ⭐ WEB EMOJI VISIBILITY FIX
                  emojiTextStyle: const TextStyle(
                    fontFamilyFallback: [
                      'Segoe UI Emoji', // Windows
                      'Apple Color Emoji', // macOS
                      'Noto Color Emoji', // Linux
                    ],
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= APP BAR =================
  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileViewScreen(user: widget.user),
          ),
        );
      },
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
          ),
          ClipOval(
            child: CachedNetworkImage(
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              imageUrl: widget.user.photoURL,
              errorWidget: (_, __, ___) =>
                  const CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: Api.firestore
                      .collection('users')
                      .doc(widget.user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final bool isOnline = data['isOnline'] ?? false;

                    return Text(
                      isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= CHAT INPUT =================
  Widget _chatInput() {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 🔹 TEXT FIELD (RESPONSIVE)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _messageController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5, // ✅ grows but stops
                textInputAction: TextInputAction.newline,
                onTap: () {
                  if (_showEmoji) {
                    setState(() => _showEmoji = false);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,

                  // 😊 EMOJI BUTTON
                  prefixIcon: IconButton(
                    icon: Icon(
                      _showEmoji
                          ? Icons.keyboard
                          : Icons.emoji_emotions_outlined,
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                  ),

                  // 🖼 IMAGE
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () async {
                      if (kIsWeb) {
                        Api.pickAndUploadImageWeb(widget.user);
                      } else {
                        final picker = ImagePicker();
                        final images = await picker.pickMultiImage();
                        if (images.isNotEmpty) {
                          Api.pickAndUploadImageWeb(widget.user);
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // 🔹 SEND BUTTON
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.green,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                final text = _messageController.text.trim();
                if (text.isEmpty) return;

                Api.sendMessage(widget.user, text);
                _messageController.clear();
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  Future<void> markAllMessagesAsRead() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('chats')
      .doc(Api.getConversationID(widget.user.uid))
      .collection('messages')
      .where('toId', isEqualTo: Api.currentUser.uid)
      .where('read', isEqualTo: 0)
      .get();

  for (final doc in snapshot.docs) {
    await doc.reference.update({
      'read': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

}

String _formatTime(BuildContext context, int milliseconds) {
  final time = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  return TimeOfDay.fromDateTime(time).format(context);
}
