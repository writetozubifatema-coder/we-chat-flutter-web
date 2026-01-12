
import 'dart:io';
import 'dart:typed_data';


import 'package:flutter/foundation.dart'; // kIsWeb

// Web-only (safe because we guard usage)
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message.dart';


class Api {
  // Firebase instances
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  // Current user model
  static late Chatuser me;
  static bool isChatScreenOpen = false;


  static User get currentUser => auth.currentUser!;

  static Future<void> updateUserInfo({
  required String name,
  required String about,
}) async {
  await firestore.collection('users').doc(me.uid).set({
  'displayName': name,
  'about': about,
}, SetOptions(merge: true));

  // update local model
  me.displayName = name;
  me.about = about;
}


  static CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // ================= USER =================

  static Future<void> ensureUserExists(User user) async {
  final doc = await users.doc(user.uid).get();

  if (doc.exists) {
    me = Chatuser.fromJson(doc.data() as Map<String, dynamic>);
  } else {
    await createUser(user);
    final newDoc = await users.doc(user.uid).get();
    me = Chatuser.fromJson(newDoc.data() as Map<String, dynamic>);
  }
}



 static Future<void> createUser(User firebaseUser) async {
  final user = Chatuser(
    uid: firebaseUser.uid,
    displayName:
        firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
    email: firebaseUser.email ?? '',
    emailVerified: firebaseUser.emailVerified,
    isAnonymous: firebaseUser.isAnonymous,
    phoneNumber: firebaseUser.phoneNumber,
    photoURL: firebaseUser.providerData.isNotEmpty
    ? firebaseUser.providerData.first.photoURL ?? ''
    : '',

    providerId: '',
    about: 'Hey there! I am using We Chat',
    metadata: Metadata(
      creationTime:
          firebaseUser.metadata.creationTime?.toIso8601String() ?? '',
      lastSignInTime:
          firebaseUser.metadata.lastSignInTime?.toIso8601String() ?? '',
    ),
    providerData: [],
    isOnline: true,
  );

  await users.doc(user.uid).set(user.toJson());
}



  
  // ================= CHAT =================

  /// Conversation ID
  static String getConversationID(String otherUid) {
    final myUid = currentUser.uid;
    final ids = [myUid, otherUid]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  static Future<void> markMessageAsRead(
      Message message, Chatuser sender) async {
    await firestore
        .collection('chats')
        .doc(getConversationID(sender.uid))
        .collection('messages')
        .doc(message.id)
        .update({
      'read': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// ================= SEND TEXT MESSAGE =================
 
static Future<void> sendMessage(Chatuser user, String msg) async {
  final time = DateTime.now().millisecondsSinceEpoch;

  final message = {
    'fromId': currentUser.uid,
    'toId': user.uid,
    'msg': msg,
    'type': Type.text.name,
    'sent': time,
    'read': 0,
  };

  final convoId = getConversationID(user.uid);

  // 1️⃣ Save message
  await firestore
      .collection('chats')
      .doc(convoId)
      .collection('messages')
      .add(message);

  // 2️⃣ UPDATE CHAT META (THIS MAKES CHAT GO TO TOP 🔥)
  await firestore.collection('chats').doc(convoId).set({
    'users': [currentUser.uid, user.uid],
    'lastMessage': msg,
    'lastMessageTime': FieldValue.serverTimestamp(),
    'lastSenderId': currentUser.uid,
  }, SetOptions(merge: true));
}

  static Future<void> updateLastMessage(Chatuser user, String msg) async {
  final time = DateTime.now().millisecondsSinceEpoch;
  final chatId = getConversationID(user.uid);

 final chatRef = firestore.collection('chats').doc(chatId);

await chatRef.set({
  'users': [currentUser.uid, user.uid],
  'lastMessage': msg,
  'lastMessageTime': time,
  'hasUnread_${user.uid}': true,
}, SetOptions(merge: true));

}



  /// ================= SEND IMAGE MESSAGES =================
 static Future<void> pickAndUploadImageWeb(Chatuser user) async {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  uploadInput.multiple = true;
  uploadInput.click();

  uploadInput.onChange.listen((event) async {
    final files = uploadInput.files;
    if (files == null || files.isEmpty) return;

    for (final file in files) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      await reader.onLoad.first;
      final bytes = Uint8List.fromList(reader.result as List<int>);


      final ref = storage.ref().child(
        'chat_images/${getConversationID(user.uid)}/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      );

      await ref.putData(bytes);

      final imageUrl = await ref.getDownloadURL();

      await firestore
          .collection('chats')
          .doc(getConversationID(user.uid))
          .collection('messages')
          .add({
        'fromId': currentUser.uid,
        'toId': user.uid,
        'msg': imageUrl,
       'sent': DateTime.now().millisecondsSinceEpoch,

        'read': DateTime.now().millisecondsSinceEpoch,

        'type': 'image',
      });
    }
  });
}


  /// ================= GET LAST MESSAGE =================
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      Chatuser user) {
    return firestore
        .collection('chats')
        .doc(getConversationID(user.uid))
        .collection('messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  /// ================= GET ALL MESSAGES =================
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    Chatuser user) {
  return firestore
      .collection('chats')
      .doc(getConversationID(user.uid))
      .collection('messages')
      .orderBy('sent', descending: true)
      .snapshots();
}


static Future<void> fixMissingPhotoURL(User firebaseUser) async {
  if (firebaseUser.photoURL == null) return;
await firestore.collection('users').doc(firebaseUser.uid).set({
  'photoURL': firebaseUser.photoURL,
}, SetOptions(merge: true));

}
static Future<void> syncProfilePhoto(User firebaseUser) async {
  final providerPhoto = firebaseUser.providerData.isNotEmpty
      ? firebaseUser.providerData.first.photoURL
      : null;

  if (providerPhoto == null || providerPhoto.isEmpty) return;

  await firestore.collection('users').doc(firebaseUser.uid).set({
  'photoURL': providerPhoto,
}, SetOptions(merge: true));

}
static Future<void> toggleBlockUser(String otherUid, bool block) async {
  final ref = firestore.collection('users').doc(currentUser.uid);

  if (block) {
   await ref.set({
  'blockedUsers': FieldValue.arrayUnion([otherUid]),
}, SetOptions(merge: true));

  } else {
    await ref.set({
  'blockedUsers': FieldValue.arrayRemove([otherUid]),
}, SetOptions(merge: true));

  }
}
static Future<void> updateActiveStatus(bool isOnline) async {
  final user = auth.currentUser;
  if (user == null) return;

  await firestore.collection('users').doc(user.uid).set({
    'isOnline': isOnline,
  }, SetOptions(merge: true));
}

static Future<void> saveUserToFirestore() async {
  final user = auth.currentUser;
  if (user == null) return;

  await firestore.collection('users').doc(user.uid).set({
    'uid': user.uid,
    'displayName': user.displayName ?? 'User',
    'email': user.email ?? '',
    'photoURL': user.photoURL ?? '',
    'isOnline': true,
    'lastActive': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}






}
