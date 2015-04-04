part of chnls_core;

class MessagesCollection extends DatabaseCollection {
  static final MessagesCollection _singleton =
      new MessagesCollection._internal();
  factory MessagesCollection() => _singleton;
  static const String MESSAGES_STORE = "messages";
  static const String INDEX_CONVERSATION = "conversation";

  MessagesCollection._internal() : super(MESSAGES_STORE);

  static void _initialize(idb.Database db) {
    if (db.objectStoreNames.contains(MESSAGES_STORE)) {
      db.deleteObjectStore(MESSAGES_STORE);
    }
    idb.ObjectStore store =
        db.createObjectStore(MESSAGES_STORE, keyPath: 'gid');
    store.createIndex(INDEX_CONVERSATION, ['conversationId','sent'], unique: false);
  }

  Stream<MessageRecord> listByConversation(String conversationId) {
    StreamController<MessageRecord> controller = new StreamController<MessageRecord>();
    _transaction().then((idb.ObjectStore store) {
      idb.KeyRange keyRange = new idb.KeyRange.bound([conversationId,  new DateTime.fromMillisecondsSinceEpoch(0)], [conversationId, new DateTime.now()]);
      store.index(INDEX_CONVERSATION).openCursor(range: keyRange, direction: 'prev', autoAdvance: true).listen((cursor) {
        MessageRecord record = new MessageRecord();
        record.fromDb(cursor.value);
        controller.add(record);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }
  
  Future<MessageRecord> add(String groupId, String conversationId, DateTime created, DateTime sent, String fromEmail, List<String> toEmail, List<String> ccEmail,
      String preamble, String subject, String htmlContent) {
    MessageRecord record = new MessageRecord.fromFields(generateUid(), groupId, conversationId, created, sent, fromEmail, 
        toEmail, ccEmail, preamble, subject, htmlContent);
    return _transaction(rw:true).then((store) {
      return store.add(record.toDb()).then((_) {
        return record;
      });
    });
  }

}

@export
class MessageRecord extends DatabaseRecord with WithGuid {
  @export String groupId;
  @export String conversationId;
  @export DateTime created;
  @export DateTime sent;
  @export String fromEmail;
  @export List<String> toEmail;
  @export List<String> ccEmail;
  @export String preamble;
  @export String subject;
  @export String htmlContent;

  MessageRecord();

  MessageRecord.fromFields(String gid, String this.groupId, String this.conversationId, DateTime this.created, DateTime this.sent, String this.fromEmail, 
      List<String> this.toEmail, List<String> this.ccEmail, String this.preamble, String this.subject, String this.htmlContent) {
    this.gid = gid;
  }
}

