part of chnls_core;

abstract class Conversation {
  String get gid;
  DateTime get created;
  DateTime get lastMessage;
  String get subject;
  
  Future<Group> get group;

  Stream<Message> get messages;
  
//  Future<DraftMessage> createDraftMessage();
//  Stream<DraftMessage> get drafts;
//  
//  Stream<Message> onNewMessage();
}
