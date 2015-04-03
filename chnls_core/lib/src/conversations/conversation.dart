part of chnls_core;

abstract class Conversation {
  String get gid;
  DateTime get created;
  DateTime get lastUpdated;
  String get subject;
  
  Group get group;
  Stream<Message> get messages;
  Stream<DraftMessage> get drafts;
  
  Stream<Message> onNewMessage();
  
  Future<DraftMessage> createDraftMessage();
}
