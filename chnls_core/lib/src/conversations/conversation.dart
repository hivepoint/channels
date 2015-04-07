part of chnls_core;

abstract class Conversation {
  String get gid;
  DateTime get created;
  DateTime get lastMessage;
  String get subject;
  
  Future<Group> get group;

  Stream<Message> get messages;
  
  Future<MessageDraft> createDraftMessage();
  Stream<MessageDraft> get drafts;
}
