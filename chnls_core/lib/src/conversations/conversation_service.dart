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
  
  Stream<Conversation> conversations() {
    StreamController<Conversation> controller = new StreamController<Conversation>();
    _store.listAll().listen((ConversationRecord record) {
      Conversation conversation = new ConversationImpl.fromDb(record);
      return conversation;      
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Stream<Conversation> getConversationsById(Set<String> conversationIds) {
    StreamController<Conversation> controller = new StreamController<Conversation>();
    _store.listByIds(conversationIds).listen((ConversationRecord record) {
      ConversationImpl conversation = new ConversationImpl.fromDb(record);
      controller.add(conversation);
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }
  
  Future<Conversation> addConversation(String emailAddress, String name, String imageUri) {
    return _store.add(emailAddress, name, imageUri).then((ConversationRecord record) {
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
  DateTime get lastUpdated => _record.lastUpdated;
  String get name => _record.name;
  
  Stream<Message> get messages {
    
  }
  
  Stream<DraftMessage> get drafts {
    
  }
  
  Stream<Message> onNewMessage() {
    
  }
  
  Future<DraftMessage> createDraft() {
    
  }
  
}
