part of chnls_core;

abstract class Message {
  String get gid;
  DateTime get created;
  DateTime get sent;
  Contact get from;
  Set<Contact> get to;
  Set<Contact> get cc;
  String get preamble; 
  String get subject;
  String get htmlContent;
}

abstract class DraftMessage {
  Future<Conversation> get conversation;
  Future<Message> send();
  Future cancel();
}