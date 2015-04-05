part of chnls_core;

enum LinkedAccountType {
  UNKNOWN, GMAIL, IMAP, XMPP
}

abstract class LinkedAccount {
  String get gid;
  String get address;
  String get name;
  LinkedAccountType get type;
}
