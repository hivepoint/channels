part of chnls_core;

abstract class Contact {
  String get gid;
  String get emailAddress;
  String get name;
  String get imageUri;
  DateTime get created;
  bool get isMe;
}
