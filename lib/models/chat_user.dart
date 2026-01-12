class Chatuser {
  Chatuser({
      
  required this.uid,
  required this.displayName,
  required this.email,
  required this.emailVerified,
  required this.isAnonymous,
  this.phoneNumber,
  required this.photoURL,
  required this.providerId,
  required this.about,
  required this.metadata,
  required this.providerData,
   required this.isOnline,
    
});
   String about;
   String uid;
   String displayName;
   String email;
   bool emailVerified;
   bool isAnonymous;
   String? phoneNumber;
   String photoURL;
   String providerId;
   Metadata metadata;
   List<ProviderData> providerData;
   bool isOnline;



factory Chatuser.fromJson(Map<String, dynamic> json) {
  return Chatuser(
    uid: json['uid'] ?? '',
    displayName: json['displayName'] ?? '',
    email: json['email'] ?? '',
    emailVerified: json['emailVerified'] is bool
        ? json['emailVerified']
        : json['emailVerified'] == 'true',
    isAnonymous: json['isAnonymous'] is bool
        ? json['isAnonymous']
        : json['isAnonymous'] == 'true',
    phoneNumber: json['phoneNumber'],
    photoURL: json['photoURL'] ?? '',
    providerId: json['providerId'] ?? '',
    about: json['about'] ?? 'Hey there! I am using We Chat',
    metadata: Metadata.fromJson(json['metadata'] ?? {}),
    providerData: (json['providerData'] as List? ?? [])
    .map((e) => ProviderData.fromJson(e))
    .toList(),

isOnline: json['isOnline'] ?? false,

);

}


 Map<String, dynamic> toJson() {
  return {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    'emailVerified': emailVerified,
    'isAnonymous': isAnonymous,
    'phoneNumber': phoneNumber,
    'photoURL': photoURL,
    'providerId': providerId,
    'about': about,
    'metadata': metadata.toJson(),
    'providerData': providerData.map((e) => e.toJson()).toList(),
'isOnline': isOnline,


  };
}
}


class Metadata {
  Metadata({
    required this.creationTime,
    required this.lastSignInTime,
  });

  final String creationTime;
  final String lastSignInTime;
  

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      creationTime: json['creationTime'] ?? '',
      lastSignInTime: json['lastSignInTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creationTime': creationTime,
      'lastSignInTime': lastSignInTime,
    };
  }
}

class ProviderData {
  ProviderData({
    required this.providerId,
    required this.uid,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    required this.photoURL,
  });

  final String providerId;
  final String uid;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String photoURL;

  factory ProviderData.fromJson(Map<String, dynamic> json) {
    return ProviderData(
      providerId: json['providerId'] ?? '',
      uid: json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      photoURL: json['photoURL'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
    };
  }
}
