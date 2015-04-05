part of chnls_core;

class MessagesCollection extends DatabaseCollection {
  static final MessagesCollection _singleton =
      new MessagesCollection._internal();
  factory MessagesCollection() => _singleton;
  static const String MESSAGES_STORE = "messages";
  static const String INDEX_CONVERSATION = "conversation";
  static const String INDEX_MESSAGE_ID = "message_id";

  MessagesCollection._internal() : super(MESSAGES_STORE);

  static void _initialize(idb.Database db) {
    if (db.objectStoreNames.contains(MESSAGES_STORE)) {
      db.deleteObjectStore(MESSAGES_STORE);
    }
    idb.ObjectStore store =
        db.createObjectStore(MESSAGES_STORE, keyPath: 'gid');
    store.createIndex(INDEX_CONVERSATION, ['conversationId', 'sent'],
        unique: false);
    store.createIndex(INDEX_MESSAGE_ID, 'messageIdHeader', unique: false);
  }

  Stream<MessageRecord> listByConversation(String conversationId) {
    StreamController<MessageRecord> controller =
        new StreamController<MessageRecord>();
    _transaction().then((idb.ObjectStore store) {
      idb.KeyRange keyRange = new idb.KeyRange.bound([
        conversationId,
        new DateTime.fromMillisecondsSinceEpoch(0)
      ], [conversationId, new DateTime.now()]);
      store
          .index(INDEX_CONVERSATION)
          .openCursor(range: keyRange, direction: 'prev', autoAdvance: true)
          .listen((cursor) {
        MessageRecord record = new MessageRecord();
        record.fromDb(cursor.value);
        controller.add(record);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }

  Future<MessageRecord> add(String groupId, String conversationId,
      DateTime created, DateTime sent, String fromEmail, List<String> toEmail,
      List<String> ccEmail, String subject, String htmlContent,
      String messageIdHeader) {
    MessageRecord record = new MessageRecord.fromFields(generateUid(), groupId,
        conversationId, created, sent, fromEmail, toEmail, ccEmail, subject,
        htmlContent, messageIdHeader, null, null);
    return _transaction(rw: true).then((store) {
      return store.add(record.toDb()).then((_) {
        return record;
      });
    });
  }
}

@export
class MessageRecord extends DatabaseRecord with WithGuid {
  @export String gid;
  @export String groupId;
  @export String conversationId;
  @export DateTime created;
  @export DateTime sent;
  @export String fromEmail;
  @export List<String> toEmail;
  @export List<String> ccEmail;
  @export String subject;
  @export String htmlContent;
  @export String messageIdHeader;
  @export String linkedAccountId;
  @export String linkedAccountMessageId;

  MessageRecord();

  MessageRecord.fromFields(String this.gid, String this.groupId,
      String this.conversationId, DateTime this.created, DateTime this.sent,
      String this.fromEmail, List<String> this.toEmail,
      List<String> this.ccEmail, String this.subject, String this.htmlContent,
      String this.messageIdHeader, String this.linkedAccountId,
      String this.linkedAccountMessageId);
}
