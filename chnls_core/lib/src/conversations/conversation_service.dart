part of chnls_core;

class ConversationService extends Service {
  static final ConversationService _singleton = new ConversationService._internal();
  factory ConversationService() => _singleton;
  StreamController<Conversation> _conversationAddedSource = new StreamController<Conversation>();
  Stream<Conversation> _conversationAddedStream;
  ConversationsCollection _store = new ConversationsCollection();

  ConversationService._internal() {
    _conversationAddedStream = _conversationAddedSource.stream.asBroadcastStream();
  }
  
  void _onStop() {
    _conversationAddedSource.close();
  }
  
  Stream<Conversation> _conversationsByGroup(String groupId) {
    StreamController<Conversation> controller = new StreamController<Conversation>();
    _store.listByGroup(groupId).listen((ConversationRecord record) {
      Conversation conversation = new ConversationImpl.fromDb(record);
      return conversation;      
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Future<Conversation> _addConversation(String groupId, String subject) {
    return _store.add(groupId, subject).then((ConversationRecord record) {
      Conversation conversation = new ConversationImpl.fromDb(record);
     _conversationAddedSource.add(conversation);
     return conversation;
    });
  }
  
  Future deleteAll() {
    return _store.removeAll();
  }
  
  Stream<Conversation> onNewConversation() {
    return _conversationAddedStream;
  }
  
  Future<Conversation> _getById(String id) {
    return _store.getById(id).then((record) {
      var group = new ConversationImpl.fromDb(record);
      return group;
    });
  }

}

class ConversationImpl extends Conversation {
  ConversationRecord _record;

  ConversationImpl.fromDb(ConversationRecord record) {
    _record = record;
  }

  String get gid => _record.gid;
  DateTime get created => _record.created;
  DateTime get lastMessage => _record.lastMessage;
  String get subject => _record.subject;

  Future<Group> get group => new GroupService()._getById(_record.groupId);
    
  Stream<Message> get messages => new MessageService()._getByConversationId(_record.gid);
}
