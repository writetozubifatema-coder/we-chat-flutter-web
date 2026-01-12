import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/widgets/profile_image_viewer.dart';


 
class ChatUserCard extends StatefulWidget {
  final Chatuser user;
  final bool hasUnread;
  final VoidCallback? onTap;



const ChatUserCard({
  super.key,
  required this.user,
  required this.hasUnread,
   this.onTap,
});

  


  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  @override
  Widget build(BuildContext context) {

    // ✅ CORRECT PLACE
    final bool isMe = widget.user.uid == Api.currentUser.uid;
    print('PHOTO URL => ${widget.user.photoURL}');


    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * .04,
        vertical: 4,
      ),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
       onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        user: widget.user,
      ),
    ),
  );
},


        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

          // 🔹 PROFILE IMAGE
          leading: GestureDetector(
onTap: widget.user.photoURL.isEmpty
    ? null
    : () => showProfileImage(context, widget.user.photoURL),


            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.withOpacity(.2),
              backgroundImage: widget.user.photoURL.isNotEmpty
                  ? CachedNetworkImageProvider(widget.user.photoURL)
                  : null,
              child: widget.user.photoURL.isEmpty
                  ? _buildInitialAvatar()
                  : null,
            ),  


),


          // 🔹 USER NAME + YOU TAG
          title: Row(
  children: [
    Flexible(
      fit: FlexFit.loose,
      child: Text(
  widget.user.displayName.isNotEmpty
      ? widget.user.displayName
      : 'User',
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    fontWeight: widget.hasUnread
    ? FontWeight.bold
    : FontWeight.w500,

  ),
),



    ),

    if (isMe) const SizedBox(width: 6),

    if (isMe)
      const Text(
        '(You)',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
  ],
),


          // 🔹 ABOUT / LAST MESSAGE
          subtitle: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: Api.getLastMessage(widget.user),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text(
                  'Say hi 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black54),
                );
              }

              final data = snapshot.data!.docs.first.data();
              final lastMsg = data['msg'] ?? '';
              final sent = data['sent'];

              String time = '';
              if (sent != null) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(sent);
                time = TimeOfDay.fromDateTime(date).format(context);
              }

              return Row(
                children: [
                  Expanded(
                    child: Text(
                      lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                  ),
                ],
              );
            },
          ),
          trailing: widget.hasUnread
    ? Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      )
    : null,


        ),
      ),
    );
  }

  // 🔹 FIRST LETTER AVATAR (NO IMAGE)
  Widget _buildInitialAvatar() {
    return Center(
      child: Text(
        widget.user.displayName.isNotEmpty
            ? widget.user.displayName[0].toUpperCase()
            : '?',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}
