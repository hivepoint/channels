part of chnls_core;

abstract class DraftMessage {
  String get htmlContent;
  Future<Conversation> get conversation;
  Future<Message> send();
  Future cancel();
  
  Future updateContent(String newHtmlContent);
}