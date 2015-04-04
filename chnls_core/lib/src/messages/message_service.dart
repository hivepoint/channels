part of chnls_core;

class MessageService extends Service {
  static final MessageService _singleton = new MessageService._internal();
  factory MessageService() => _singleton;
  StreamController<Message> _messageAddedSource = new StreamController<Message>();
  Stream<Message> _messageAddedStream;
  MessagesCollection _store = new MessagesCollection();

  MessageService._internal() {
    _messageAddedStream = _messageAddedSource.stream.asBroadcastStream();
  }
  
  void _onStop() {
    _messageAddedSource.close();
  }
  
  Stream<Message> _getByConversationId(String conversationId) {
    StreamController<Message> controller = new StreamController<Message>();
    _store.listByConversation(conversationId).listen((MessageRecord record) {
      Message message = new MessageImpl.fromDb(record);
      return message;      
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }
  
  Future deleteAll() {
    return _store.removeAll();
  }
  
  Stream<Message> onNewMessage() {
    return _messageAddedStream;
  }
  
  Future<MessageDraft> createMessageDraft(Conversation conversation) {
    throw new UnimplementedError();    
  }
}

class MessageImpl extends Message {
  MessageRecord _record;

  MessageImpl.fromDb(MessageRecord record) {
    _record = record;
  }

  String get gid => _record.gid;
  DateTime get created => _record.created;
  DateTime get sent => _record.sent;

  String get subject => _record.subject;
  String get preamble => _record.preamble;


  Future<Contact> get from {
    return new ContactService().getContactByEmail(_record.fromEmail);
  }
  
  Stream<Contact> get to {
    return new ContactService().getContactsByEmail(_record.toEmail);
  }

  Stream<Contact> get cc => new ContactService().getContactsByEmail(_record.ccEmail);

  Future<Group> get group => new GroupService()._getById(_record.groupId);
    
  Future<Conversation> get conversation => new ConversationService()._getById(_record.conversationId);
  
  Future<String> get htmlContent => new Future<String>(() { return _record.htmlContent;});
}

class MessageDraftImpl extends MessageDraft {
  MessageDraftRecord _record;

  MessageDraftImpl.fromDb(MessageDraftRecord record) {
    _record = record;
  }

  String get gid => _record.gid;
  DateTime get created => _record.created;
  DateTime get lastUpdated => _record.lastUpdated;
  String get htmlContent => _record.htmlContent;

  Future<Group> get group => new GroupService()._getById(_record.groupId);
    
  Future<Conversation> get conversation => new ConversationService()._getById(_record.conversationId);

  Future<Message> send() {
    throw new UnimplementedError();
  }
  
  Future cancel() {
    throw new UnimplementedError();
  }
  
  Future updateContent(String htmlContent) {
    throw new UnimplementedError();
  }
}
