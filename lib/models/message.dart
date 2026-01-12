

enum Type { text, image }

class Message {
  final String id; // ⭐ ADD THIS
  final String fromId;
  final String toId;
  final String msg;
  final int sent;
  final int read;
  final Type type;

  Message({
  required this.id, // ⭐ ADD
  required this.fromId,
  required this.toId,
  required this.msg,
  required this.sent,
  required this.read,
  required this.type,
});


  Map<String, dynamic> toJson() {
    return {
      'fromId': fromId,
      'toId': toId,
      'msg': msg,
      'sent': sent,
'read': read,

      'type': type.name, // ✅ text / image
    };
  }

factory Message.fromJson(Map<String, dynamic> json, String id) {
  return Message(
    id: id,
    fromId: json['fromId'],
    toId: json['toId'],
    msg: json['msg'],

    sent: json['sent'] ?? 0,
read: json['read'] ?? 0,

    type: json['type'] == 'image' ? Type.image : Type.text,
  );
}

}
