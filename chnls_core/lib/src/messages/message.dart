part of chnls_core;

abstract class Message {
  String get gid;
  DateTime get created;
  DateTime get sent;
  Future<Contact> get from;
  Stream<Contact> get to;
  Stream<Contact> get cc;
  String get subject;
  String get htmlContent;
  String get messageIdHeader;
  Future<LinkedAccount> get linkedAccount;
  String get linkedAccountMessageId;
  
  Future<Conversation> get conversation;
  
  Future<Group> get group;
}
