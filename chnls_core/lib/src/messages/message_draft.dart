part of chnls_core;

abstract class MessageDraft {
  String get gid;
  DateTime get created;
  DateTime get lastUpdated;
  String get htmlContent;

  Future<Conversation> get conversation;
  Future<Group> get group;
  Future<Message> send();
  Future cancel();
  
  Future<MessageDraft> updateContent(String newHtmlContent);
}