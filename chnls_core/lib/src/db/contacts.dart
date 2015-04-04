part of chnls_core;

class ContactsCollection extends DatabaseCollection {
  static final ContactsCollection _singleton =
      new ContactsCollection._internal();
  factory ContactsCollection() => _singleton;
  static const String CONTACTS_STORE = "contacts";
  static const String INDEX_EMAIL = "email";

  ContactsCollection._internal() : super(CONTACTS_STORE);

  static void _initialize(idb.Database db) {
    if (db.objectStoreNames.contains(CONTACTS_STORE)) {
      db.deleteObjectStore(CONTACTS_STORE);
    }
    idb.ObjectStore store =
        db.createObjectStore(CONTACTS_STORE, autoIncrement: true);
    store.createIndex(INDEX_GID, INDEX_GID, unique: true);
    store.createIndex(INDEX_EMAIL, INDEX_EMAIL, unique: true);
  }

  Stream<ContactRecord> listAll() {
    StreamController<ContactRecord> controller = new StreamController<ContactRecord>();
    _transaction().then((store) {
      store.openCursor(autoAdvance: true).listen((idb.CursorWithValue value) {
        ContactRecord record = new ContactRecord();
        record.fromDb(value.value);
        controller.add(record);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }

  Stream<ContactRecord> listByIds(Set<String> contactIds) {
    StreamController<ContactRecord> controller = new StreamController<ContactRecord>();
    if (contactIds.isEmpty) {
      controller.close();
    } else {
      int count = 0;
      _transaction().then((store) {
        contactIds.forEach((contactId) {
          store.index(INDEX_GID).get(contactId).then((Object value) {
            ContactRecord record = new ContactRecord();
            record.fromDb(value);
            controller.add(record);
            count++;
            if (count == contactIds.length) {
              controller.close();
            }
          });
        });
      });
    }
    return controller.stream;
  }
  
  Future<ContactRecord> getByEmail(String emailAddress) {
    return _transaction().then((store) {
      return store.index(INDEX_EMAIL).get(emailAddress.toLowerCase()).then((idb.CursorWithValue cursor) {
        GroupRecord record = new GroupRecord();
        record.fromDb(cursor.value);
        return record;
      });
    });
  }
  
  Stream<ContactRecord> listByEmailAddresses(Set<String> emailAddresses) {
    StreamController<ContactRecord> controller = new StreamController<ContactRecord>();
    if (emailAddresses.isEmpty) {
      controller.close();
    } else {
      int count = 0;
      _transaction().then((store) {
        emailAddresses.forEach((emailAddress) {
          store.index(INDEX_EMAIL).get(emailAddress.toLowerCase()).then((Object value) {
            ContactRecord record = new ContactRecord();
            record.fromDb(value);
            controller.add(record);
            count++;
            if (count == emailAddresses.length) {
              controller.close();
            }
          });
        });
      });
    }
    return controller.stream;    
  }
  
  Future<ContactRecord> add(String emailAddress, String name, String imageUri) {
    ContactRecord record = new ContactRecord.fromFields(generateUid(), emailAddress.toLowerCase(), name, new DateTime.now(), imageUri);
    return _transaction(rw:true).then((store) {
      return store.add(record.toDb()).then((_) {
        return record;
      });
    });
  }

}

@export
class ContactRecord extends DatabaseRecord with WithGuid {
  @export String email;
  @export String emailWithCase;
  @export String name;
  @export DateTime created;
  @export String imageUri;

  ContactRecord();

  ContactRecord.fromFields(String gid, String this.emailWithCase,
      String this.name, DateTime this.created, String this.imageUri) {
    this.gid = gid;
    this.email = emailWithCase.toLowerCase();
  }
}

