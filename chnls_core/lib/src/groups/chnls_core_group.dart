part of chnls_core;

abstract class Group  {
  String get gid;
  DateTime get created;
  String get name;
  
  Future<Set<Contact>> get people;
  Stream<Conversation> get conversations;

  Stream<Conversation> onNewConversation();
  Future<Conversation> createConversation(String topic, Set<String> contacts);
}

