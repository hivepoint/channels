part of chnls_core;

abstract class Group  {
  String get gid;
  DateTime get created;
  String get name;
  String get tileColor;
  
  Stream<Contact> get people;
  Stream<Conversation> get conversations;

  Stream<Conversation> onNewConversation();
  Future<Conversation> createConversation(String topic, Set<String> contacts);
}

