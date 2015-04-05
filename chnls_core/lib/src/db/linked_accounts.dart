part of chnls_core;

class LinkedAccountsCollection extends DatabaseCollection {
  static final LinkedAccountsCollection _singleton =
      new LinkedAccountsCollection._internal();
  factory LinkedAccountsCollection() => _singleton;
  static const String LINKED_ACCOUNTS_STORE = "linked_accounts";

  LinkedAccountsCollection._internal() : super(LINKED_ACCOUNTS_STORE);

  static void _initialize(idb.Database db) {
    if (db.objectStoreNames.contains(LINKED_ACCOUNTS_STORE)) {
      db.deleteObjectStore(LINKED_ACCOUNTS_STORE);
    }
    db.createObjectStore(LINKED_ACCOUNTS_STORE, keyPath: 'gid');
  }

  Stream<LinkedAccountRecord> listAll() {
    StreamController<LinkedAccountRecord> controller =
        new StreamController<LinkedAccountRecord>();
    _transaction().then((store) {
      store.openCursor(autoAdvance: true).listen((idb.CursorWithValue value) {
        LinkedAccountRecord record = new LinkedAccountRecord();
        record.fromDb(value.value);
        controller.add(record);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }

  Future<LinkedAccountRecord> add(
      String address, String name, LinkedAccountType type) {
    LinkedAccountRecord record =
        new LinkedAccountRecord.fromFields(generateUid(), address, name, type);
    return _transaction(rw: true).then((store) {
      return store.add(record.toDb()).then((_) {
        return record;
      });
    });
  }
  
  Future<LinkedAccountRecord> getById(String id) {
    return _transaction().then((store) {
      return store.index(INDEX_GID).get(id).then((idb.CursorWithValue cursor) {
        LinkedAccountRecord record = new LinkedAccountRecord();
        record.fromDb(cursor.value);
        return record;
      });
    });
  }

}

@export
class LinkedAccountRecord extends DatabaseRecord with WithGuid {
  @export String gid;
  @export String address;
  @export String name;
  @export String type_string;

  LinkedAccountRecord();

  LinkedAccountRecord.fromFields(String this.gid, String this.address,
      String this.name, LinkedAccountType type) {
    this.type_string = type.toString();
  }

  LinkedAccountType get type {
    LinkedAccountType.values.forEach((LinkedAccountType value) {
      if (value.toString() == type_string) {
        return value;
      }
    });
    return LinkedAccountType.UNKNOWN;
  }
}
