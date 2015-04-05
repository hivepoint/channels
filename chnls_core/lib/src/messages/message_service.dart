part of chnls_core;

class MessageService extends Service {
  static final MessageService _singleton = new MessageService._internal();
  factory MessageService() => _singleton;
  StreamController<Message> _messageAddedSource =
      new StreamController<Message>();
  Stream<Message> _messageAddedStream;
  MessagesCollection _store = new MessagesCollection();
  MessageDraftsCollection _draftsStore = new MessageDraftsCollection();

  MessageService._internal() {
    _messageAddedStream = _messageAddedSource.stream.asBroadcastStream();
  }

  void _onStop() {
    _messageAddedSource.close();
  }

  Stream<Message> _getByConversationId(String conversationId) {
    var controller = new StreamController<Message>();
    _store.listByConversation(conversationId).listen((MessageRecord record) {
      Message message = new MessageImpl.fromDb(record);
      return message;
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Stream<MessageDraft> _getDraftsByConversationId(String conversationId) {
    var controller = new StreamController<MessageDraft>();
    _draftsStore
        .listByConversation(conversationId)
        .listen((MessageDraftRecord record) {
      MessageDraft message = new MessageDraftImpl.fromDb(record);
      return message;
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Future deleteAll() {
    return _store.removeAll();
  }
  
  Future deleteAllDrafts() {
    return _draftsStore.removeAll();
  }

  Stream<Message> onNewMessage() {
    return _messageAddedStream;
  }

  Future<MessageDraft> _createMessageDraft(
      String groupId, String conversationId) {
    var now = new DateTime.now();
    return _draftsStore
        .add(groupId, conversationId, now, now, "")
        .then((MessageDraftRecord record) {
      return new MessageDraftImpl.fromDb(record);
    });
  }

  Future<Message> _sendDraft(MessageDraftRecord record) {
    var now = new DateTime.now();
    return _store
        .add(record.gid, record.conversationId, now, now, null, null, null,
            null, record.htmlContent, "<" + record.gid + "@braid.cc")
        .then((MessageRecord record) {
      return new MessageImpl.fromDb(record);
    });
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

  Future<Contact> get from {
    return new ContactService().getContactByEmail(_record.fromEmail);
  }

  Stream<Contact> get to {
    return new ContactService().getContactsByEmail(_record.toEmail);
  }

  Stream<Contact> get cc =>
      new ContactService().getContactsByEmail(_record.ccEmail);

  Future<Group> get group => new GroupService()._getById(_record.groupId);

  Future<Conversation> get conversation =>
      new ConversationService()._getById(_record.conversationId);

  String get htmlContent => _record.htmlContent;
  
  String get messageIdHeader => _record.messageIdHeader;
  
  String get linkedAccountMessageId => _record.linkedAccountMessageId;
  
  Future<LinkedAccount> get linkedAccount => new AccountService()._linkedAccountById(_record.linkedAccountId);
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

  Future<Conversation> get conversation =>
      new ConversationService()._getById(_record.conversationId);

  Future<Message> send() {
    return new MessageService()._sendDraft(_record).whenComplete(() {
      new MessageDraftsCollection().removeById(_record.gid);
    });
  }

  Future cancel() => new MessageDraftsCollection().removeById(_record.gid);

  Future<MessageDraft> updateContent(String htmlContent) =>
      new MessageDraftsCollection().updateContents(_record.gid, htmlContent)
      .then((MessageDraftRecord record) => new MessageDraftImpl.fromDb(record));
}
