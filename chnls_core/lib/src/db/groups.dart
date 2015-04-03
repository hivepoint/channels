part of chnls_core;

class GroupsCollection extends DatabaseCollection {
  static final GroupsCollection _singleton = new GroupsCollection._internal();
  factory GroupsCollection() => _singleton;
  static const String GROUPS_STORE = "groups";
  ContactsService contactsService = new ContactsService();

  GroupsCollection._internal() : super(GROUPS_STORE);

  static void _initialize(idb.Database db) {
    if (db.objectStoreNames.contains(GROUPS_STORE)) {
      db.deleteObjectStore(GROUPS_STORE);
    }
    idb.ObjectStore store =
        db.createObjectStore(GROUPS_STORE, autoIncrement: true);
    store.createIndex(INDEX_GID, INDEX_GID, unique: true);
  }

  Stream<GroupRecord> listAll() {
    StreamController<GroupRecord> controller = new StreamController<GroupRecord>();
    _transaction().then((store) {
      store.openCursor(autoAdvance: true).listen((idb.CursorWithValue value) {
        GroupRecord record = new GroupRecord();
        record.fromDb(value.value);
        controller.add(record);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }

  Future<GroupRecord> setTileColor(GroupRecord record, String color) {
    GroupRecord record = new GroupRecord();
    return fetchAndUpdate(record.gid, (Object recordValue) {
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
        generateUid(), name, now, now, tileColor);
    record.contactIds.addAll(contactIds);
    return _transaction(rw: true).then((store) {
      return store.add(record.toDb()).then((_) {
        return record;
      });
    });
  }
  
  Future<GroupRecord> getById(String groupId) {
    return _transaction().then((store) {
      return store.index(INDEX_GID).get(groupId).then((idb.CursorWithValue cursor) {
        GroupRecord record = new GroupRecord();
        record.fromDb(cursor.value);
        return record;
      });
    });
  }
}

@export
class GroupRecord extends DatabaseRecord with WithGuid {
  @export String name;
  @export DateTime created;
  @export DateTime lastUpdated;
  @export Set<String> contactIds = new Set<String>();
  @export String tileColor;

  GroupRecord();
  GroupRecord.fromFields(String gid, String this.name, DateTime this.created, DateTime this.lastUpdated,
      String this.tileColor) {
    this.gid = gid;
  }
}
