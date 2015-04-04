part of chnls_core;

class MessagesService extends Service {
  static final MessagesService _singleton = new MessagesService._internal();
  factory MessagesService() => _singleton;
  StreamController<Message> _messageAddedSource = new StreamController<Message>();
  Stream<Message> _messageAddedStream;
  MessagesCollection _store = new MessagesCollection();

  MessagesService._internal() {
    _messageAddedStream = _messageAddedSource.stream.asBroadcastStream();
  }
  
  void _onStop() {
    _messageAddedSource.close();
  }
  
  Stream<Message> messagesByConversationId(String conversationId) {
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

  Future<Group> get group => new GroupService().getById(_record.groupId);
    
  Future<Conversation> get conversation => new ConversationService().getById(_record.conversationId);
  
  Future<String> get htmlContent => new Future<String>(() { return _record.htmlContent;});
}
