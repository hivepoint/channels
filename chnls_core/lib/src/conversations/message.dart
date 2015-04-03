part of chnls_core;

abstract class Message {
  String gid;
  DateTime created;
  DateTime sent;
  DateTime lastUpdated;
  Contact from;
  Set<Contact> to;
  Set<Contact> cc;
  String preamble;
  String subject;
  String htmlContent;
}

abstract class DraftMessage {
  Conversation conversation;
  Future<Message> send();
  Future cancel();
}