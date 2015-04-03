part of chnls_core;

class ConversationsService extends Service {
  static final ConversationsService _singleton = new ConversationsService._internal();
  factory ConversationsService() => _singleton;
  StreamController<Conversation> _conversationAddedSource = new StreamController<Conversation>();
  Stream<Conversation> _conversationAddedStream;
  ConversationsCollection _store = new ConversationsCollection();

  ConversationsService._internal() {
    _conversationAddedStream = _conversationAddedSource.stream.asBroadcastStream();
  }
  
  void _onStop() {
    _conversationAddedSource.close();
  }
  
  Stream<Conversation> conversationsByGroup(String groupId) {
    StreamController<Conversation> controller = new StreamController<Conversation>();
    _store.listByGroup(groupId).listen((ConversationRecord record) {
      Conversation conversation = new ConversationImpl.fromDb(record);
      return conversation;      
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Future<Conversation> addConversation(String groupId, String subject) {
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

  Future<Group> get group {
    GroupsService groupsService = new GroupsService();
    return groupsService.getById(_record.groupId);
  }
    
}
