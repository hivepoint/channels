part of chnls_core;

class MessageService extends Service {
  static final MessageService _singleton = new MessageService._internal();
  factory MessageService() => _singleton;
  StreamController<Message> _messageAddedSource = new StreamController<Message>();
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
    _draftsStore.listByConversation(conversationId).listen((MessageDraftRecord record) {
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

  Future<MessageDraft> _createMessageDraft(String groupId, String conversationId) {
    var now = new DateTime.now();
    return _draftsStore.add(groupId, conversationId, now, now, "").then((MessageDraftRecord record) {
      return new MessageDraftImpl.fromDb(record);
    });
  }

  Future<Message> _sendDraft(MessageDraftRecord record) {
    return new GroupService()._getById(record.groupId)
        .then((Group group) => group.people)
        .then((Stream<Contact> memberStream) => memberStream.toList())
        .then((List<Contact> members) {
      Contact me;
      List<String> recipients = new List<String>();
      members.forEach((Contact member) {
        if (member.isMe) {
          me = member;
        } else {
          recipients.add(member.emailAddress);
        }
      });
      return new ConversationService()
          ._getById(record.conversationId)
          .then((Conversation c) => new AccountService().deliverEmail(new DeliverableMessageImpl.fromDraft(record, me, recipients, c)))
          .then((DeliverableMessage updatedMessage) => _store.add(updatedMessage.record))
          .then((MessageRecord finalRecord) => new MessageImpl.fromDb(finalRecord));
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
  String get fromAddress => _record.fromEmail;
  String get linkedAccountId => _record.linkedAccountId;
  String get linkedAccountMessageId => _record.linkedAccountMessageId;
  String get linkedAccountThreadId => _record.linkedAccountThreadId;

  String get subject => _record.subject;

  Future<Contact> get from {
    return new ContactService().getContactByEmail(_record.fromEmail);
  }

  Stream<Contact> get to {
    return new ContactService().getContactsByEmail(_record.toEmail);
  }

  Stream<Contact> get cc => new ContactService().getContactsByEmail(_record.ccEmail);

  Future<Group> get group => new GroupService()._getById(_record.groupId);

  Future<Conversation> get conversation => new ConversationService()._getById(_record.conversationId);

  String get htmlContent => _record.htmlContent;

  String get messageIdHeader => _record.messageIdHeader;

  Future<LinkedAccount> get linkedAccount => new AccountService()._linkedAccountById(_record.linkedAccountId);

  String toString() {
    return 'Message(' + _record.gid + ') ' + subject;
  }
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
    return new MessageService()._sendDraft(_record)
        .whenComplete(() {
      new MessageDraftsCollection().removeById(_record.gid);
    });
  }

  Future cancel() => new MessageDraftsCollection().removeById(_record.gid);

  Future<MessageDraft> updateContent(String htmlContent) =>
      new MessageDraftsCollection().updateContents(_record.gid, htmlContent).then((MessageDraftRecord record) => new MessageDraftImpl.fromDb(record));
}

class DeliverableMessageImpl extends DeliverableMessage {
  MessageRecord _record;

  DeliverableMessageImpl.fromDraft(MessageDraftRecord draft, Contact me, List<String> recipientAddresses, Conversation conversation) {
    _record = new MessageRecord.fromFields(
        draft.gid, draft.groupId, draft.conversationId, draft.created, null, me.emailAddress, recipientAddresses, null, conversation.subject, draft.htmlContent, null, null, null, null);
  }

  set sent(DateTime value) => _record.sent = value;
  set linkedAccountId(String value) => _record.linkedAccountId = value;
  set linkedAccountMessageId(String value) => _record.linkedAccountMessageId = value;
  set linkedAccountThreadId(String value) => _record.linkedAccountThreadId = value;
  set messageIdHeader(String value) => _record.messageIdHeader = value;

  String get gid => _record.gid;
  DateTime get created => _record.created;
  DateTime get sent => _record.sent;
  String get fromAddress => _record.fromEmail;
  String get linkedAccountId => _record.linkedAccountId;
  String get linkedAccountMessageId => _record.linkedAccountMessageId;
  String get linkedAccountThreadId => _record.linkedAccountThreadId;

  String get subject => _record.subject;

  MessageRecord get record => _record;

  Future<Contact> get from {
    return new ContactService().getContactByEmail(_record.fromEmail);
  }

  Stream<Contact> get to {
    return new ContactService().getContactsByEmail(_record.toEmail);
  }

  Stream<Contact> get cc => new ContactService().getContactsByEmail(_record.ccEmail);

  Future<Group> get group => new GroupService()._getById(_record.groupId);

  Future<Conversation> get conversation => new ConversationService()._getById(_record.conversationId);

  String get htmlContent => _record.htmlContent;

  String get messageIdHeader => _record.messageIdHeader;

  Future<LinkedAccount> get linkedAccount => new AccountService()._linkedAccountById(_record.linkedAccountId);

  String toString() {
    return 'DeliverableMessage(' + _record.gid + ') ' + subject;
  }
}
