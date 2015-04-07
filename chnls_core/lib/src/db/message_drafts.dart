part of chnls_core;

class MessageDraftsCollection extends DatabaseCollection {
  static final MessageDraftsCollection _singleton =
      new MessageDraftsCollection._internal();
  factory MessageDraftsCollection() => _singleton;
  static const String MESSAGE_DRAFTS_STORE = "message_drafts";
  static const String INDEX_CONVERSATION = "conversation";

  MessageDraftsCollection._internal() : super(MESSAGE_DRAFTS_STORE);

  static void _initialize(idb.Database db) {
    if (db.objectStoreNames.contains(MESSAGE_DRAFTS_STORE)) {
      db.deleteObjectStore(MESSAGE_DRAFTS_STORE);
    }
    idb.ObjectStore store =
        db.createObjectStore(MESSAGE_DRAFTS_STORE, keyPath: 'gid');
    store.createIndex(INDEX_CONVERSATION, ['conversationId','lastUpdated'], unique: false);
  }

  Stream<MessageDraftRecord> listByConversation(String conversationId) {
    StreamController<MessageDraftRecord> controller = new StreamController<MessageDraftRecord>();
    _transaction().then((idb.ObjectStore store) {
      idb.KeyRange keyRange = new idb.KeyRange.bound([conversationId,  new DateTime.fromMillisecondsSinceEpoch(0)], [conversationId, new DateTime.now()]);
      store.index(INDEX_CONVERSATION).openCursor(range: keyRange, direction: 'prev', autoAdvance: true).listen((cursor) {
        MessageDraftRecord record = new MessageDraftRecord();
        record.fromDb(cursor.value);
        controller.add(record);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }
  
  Future<MessageDraftRecord> add(String groupId, String conversationId, DateTime created, DateTime lastUpdated, String htmlContent) {
    MessageDraftRecord record = new MessageDraftRecord.fromFields(generateUid(), groupId, conversationId, created, lastUpdated, htmlContent); 
    return _transaction(rw:true).then((store) {
      return store.add(record.toDb()).then((_) {
        return record;
      });
    });
  }
  
  Future<MessageDraftRecord> updateContents(String id, String newContents) {
    var record = new MessageDraftRecord();
    return fetchAndUpdate(id, (Object recordValue) {
      record.fromDb(recordValue);
      record.htmlContent = newContents;
      record.lastUpdated = new DateTime.now();
      return record.toDb();
    }).then((_) {
       return record;   
    });
  }
}

@export
class MessageDraftRecord extends DatabaseRecord with WithGuid {
  @export String gid;
  @export String groupId;
  @export String conversationId;
  @export DateTime created;
  @export DateTime lastUpdated;
  @export String htmlContent;

  MessageDraftRecord();

  MessageDraftRecord.fromFields(String this.gid, String this.groupId, String this.conversationId, DateTime this.created, DateTime this.lastUpdated, String this.htmlContent);
}

