part of chnls_core;

class ConversationsCollection extends DatabaseCollection {
  static final ConversationsCollection _singleton = new ConversationsCollection._internal();
  factory ConversationsCollection() => _singleton;
  static const String CONVERSATIONS_STORE = "conversations";
  ContactsService contactsService = new ContactsService();

  ConversationsCollection._internal() : super(CONVERSATIONS_STORE);

  static void _initialize(idb.Database db) {
    if (db.objectStoreNames.contains(CONVERSATIONS_STORE)) {
      db.deleteObjectStore(CONVERSATIONS_STORE);
    }
    idb.ObjectStore store =
        db.createObjectStore(CONVERSATIONS_STORE, autoIncrement: true);
    store.createIndex(INDEX_GID, INDEX_GID, unique: true);
  }

  Stream<ConversationRecord> listAll() {
    StreamController<ConversationRecord> controller = new StreamController<ConversationRecord>();
    _transaction().then((store) {
      store.openCursor(autoAdvance: true).listen((idb.CursorWithValue value) {
        ConversationRecord record = new ConversationRecord();
        record.fromDb(value.value);
        controller.add(record);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }

  Future<ConversationRecord> add(String subject) {
    DateTime now = new DateTime.now();
    ConversationRecord record = new ConversationRecord.fromFields(
        generateUid(), now, now, subject);
    return _transaction(rw: true).then((store) {
      return store.add(record.toDb()).then((_) {
        return record;
      });
    });
  }
}

@export
class ConversationRecord extends DatabaseRecord with WithGuid {
  @export DateTime created;
  @export DateTime lastUpdated;
  @export String groupId;
  @export Set<String> contactIds = new Set<String>();
  @export Set<String> messageIds = new Set<String>();
  @export Set<String> draftIds = new Set<String>();

  ConversationRecord();
  ConversationRecord.fromFields(String gid, DateTime this.created, DateTime this.lastUpdated,
      String this.groupId, String this.subject) {
    this.gid = gid;
  }
}
