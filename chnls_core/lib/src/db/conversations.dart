part of chnls_core;

class ConversationsCollection extends DatabaseCollection {
  static final ConversationsCollection _singleton = new ConversationsCollection._internal();
  factory ConversationsCollection() => _singleton;
  static const String CONVERSATIONS_STORE = "conversations";
  static const String INDEX_GROUP = "group";
  ContactService contactService = new ContactService();

  ConversationsCollection._internal() : super(CONVERSATIONS_STORE);

  static void _initialize(idb.Database db) {
    if (db.objectStoreNames.contains(CONVERSATIONS_STORE)) {
      db.deleteObjectStore(CONVERSATIONS_STORE);
    }
    idb.ObjectStore store =
        db.createObjectStore(CONVERSATIONS_STORE, keyPath: 'gid');
    store.createIndex(INDEX_GROUP, ['groupId','lastMessage'], unique: false);
  }

  Stream<ConversationRecord> listByGroup(String groupId) {
    StreamController<ConversationRecord> controller = new StreamController<ConversationRecord>();
    _transaction().then((idb.ObjectStore store) {
      idb.KeyRange keyRange = new idb.KeyRange.bound([groupId,  new DateTime.fromMillisecondsSinceEpoch(0)], [groupId, new DateTime.now()]);
      store.index(INDEX_GROUP).openCursor(range: keyRange, direction: 'prev', autoAdvance: true).listen((cursor) {
        ConversationRecord record = new ConversationRecord();
        record.fromDb(cursor.value);
        controller.add(record);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }

  Future<ConversationRecord> add(String groupId, String subject) {
    DateTime now = new DateTime.now();
    ConversationRecord record = new ConversationRecord.fromFields(
        generateUid(), now, new DateTime.fromMillisecondsSinceEpoch(0), groupId, subject);
    return _transaction(rw: true).then((store) {
      return store.add(record.toDb()).then((_) {
        return record;
      });
    });
  }
  
  Future<ConversationRecord> getById(String id) {
    return _transaction().then((store) {
      return store.getObject(id).then((r) {
        ConversationRecord record = new ConversationRecord();
        record.fromDb(r);
        return record;
      });
    });
  }
 

}

@export
class ConversationRecord extends DatabaseRecord with WithGuid {
  @export String gid;
  @export DateTime created;
  @export DateTime lastMessage;
  @export String groupId;
  @export String subject;

  ConversationRecord();
  ConversationRecord.fromFields(String this.gid, DateTime this.created, DateTime this.lastMessage,
      String this.groupId, String this.subject) {
    this.gid = gid;
  }
}
