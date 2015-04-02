part of chnls_core;

abstract class Conversation {
  String gid;
  DateTime created;
  String name;
  Set<Contact> people;
  Stream<Message> messages;
  Stream<DraftMessage> drafts;
  
  Stream<Message> onNewMessage();
  
  Future<DraftMessage> createDraftMessage();
}
