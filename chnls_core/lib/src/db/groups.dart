part of chnls_core;

class GroupsCollection extends DatabaseCollection {
  static final GroupsCollection _singleton = new GroupsCollection._internal();
  factory GroupsCollection() => _singleton;
  static const String GROUPS_STORE = "groups";
  static const String INDEX_LAST_UPDATED = "last_updated";
  ContactService contactService = new ContactService();

  GroupsCollection._internal() : super(GROUPS_STORE);

  static void _initialize(idb.Database db) {
    if (db.objectStoreNames.contains(GROUPS_STORE)) {
      db.deleteObjectStore(GROUPS_STORE);
    }
    var store = db.createObjectStore(GROUPS_STORE,  keyPath: 'gid');
    store.createIndex(INDEX_LAST_UPDATED, 'lastUpdated', unique: false);
  }

  Stream<GroupRecord> listAll() {
    StreamController<GroupRecord> controller = new StreamController<GroupRecord>();
    _transaction().then((store) {
      store.index(INDEX_LAST_UPDATED).openCursor(autoAdvance: true).listen((idb.CursorWithValue value) {
        GroupRecord record = new GroupRecord();
        record.fromDb(value.value);
        controller.add(record);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }

  Future<GroupRecord> setTileColor(String id, String color) {
    GroupRecord record = new GroupRecord();
    return fetchAndUpdate(id, (Object recordValue) {
      record.fromDb(recordValue);
      record.tileColor = color;
      record.lastUpdated = new DateTime.now();
      return record.toDb();
    }).then((_) {
       return record;   
    });
  }

  Future<GroupRecord> add(
      String name, List<String> contactIds, String tileColor) {
    DateTime now = new DateTime.now();
    GroupRecord record = new GroupRecord.fromFields(
        generateUid(), name, now, now, tileColor, contactIds);
    return _transaction(rw: true).then((store) {
      return store.add(record.toDb()).then((_) {
        return record;
      });
    });
  }
  
  Future<GroupRecord> getById(String groupId) {
    return _transaction().then((store) {
      return store.getObject(groupId).then((r) {
        GroupRecord record = new GroupRecord();
        record.fromDb(r);
        return record;
      });
    });
  }
}

@export
class GroupRecord extends DatabaseRecord with WithGuid {
  @export String gid;
  @export String name;
  @export DateTime created;
  @export DateTime lastUpdated;
  @export List<String> contactIds = new List<String>();
  @export String tileColor;

  GroupRecord();
  GroupRecord.fromFields(String this.gid, String this.name, DateTime this.created, DateTime this.lastUpdated,
      String this.tileColor, List<String> this.contactIds);
}
