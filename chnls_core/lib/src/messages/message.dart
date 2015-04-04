part of chnls_core;

abstract class Message {
  String get gid;
  DateTime get created;
  DateTime get sent;
  Future<Contact> get from;
  Stream<Contact> get to;
  Stream<Contact> get cc;
  String get preamble; 
  String get subject;
  Future<String> get htmlContent;
  
  Future<Conversation> get conversation;
  
  Future<Group> get group;
}
