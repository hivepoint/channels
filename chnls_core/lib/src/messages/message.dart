part of chnls_core;

abstract class Message {
  String get gid;
  DateTime get created;
  DateTime get sent;
  String get fromAddress;
  Future<Contact> get from;
  Stream<Contact> get to;
  Stream<Contact> get cc;
  String get subject;
  String get htmlContent;
  String get messageIdHeader;
  Future<LinkedAccount> get linkedAccount;
  String get linkedAccountMessageId;
  String get linkedAccountThreadId;
  
  Future<Conversation> get conversation;
  
  Future<Group> get group;
  
  String toString();
}

abstract class DeliverableMessage extends Message {
   set sent(DateTime value);
   set linkedAccountId(String value);
   set linkedAccountMessageId(String value);
   set linkedAccountThreadId(String value);
   set messageIdHeader(String value);
   
   MessageRecord get record;
}
