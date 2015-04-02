part of chnls_core;

abstract class Group  {
  String gid;
  DateTime created;
  String name;
  Set<String> contactIds;
  
  Future<Set<Contact>> get people;
  Stream<Conversation> get conversations;

  Stream<Conversation> onNewConversation();
  Future<Conversation> createConversation(String topic, Set<String> contacts);
}

