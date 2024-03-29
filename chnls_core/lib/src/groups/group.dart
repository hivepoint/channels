part of chnls_core;

abstract class Group  {
  String get gid;
  DateTime get created;
  DateTime get lastUpdated;
  String get name;
  String get tileColor;
  
  Future<Group> setTileColor(String color);
  
  Stream<Contact> get people;
  Stream<Conversation> get conversations;

  Future<Conversation> createConversation(String subject);
}

