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

  Stream<Contact> listAll() {
    StreamController<Contact> controller = new StreamController<Contact>();
    _transaction().then((store) {
      store.openCursor(autoAdvance: true).listen((idb.CursorWithValue value) {
        ContactRecord record = new ContactRecord();
        record.fromDb(value.value);
        Contact contact = new ContactImpl.fromDb(record);
        controller.add(contact);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }

  Stream<Contact> listByIds(Set<String> contactIds) {
    StreamController<Contact> controller = new StreamController<Contact>();
    if (contactIds.isEmpty) {
      controller.close();
    } else {
      int count = 0;
      _transaction().then((store) {
        contactIds.forEach((contactId) {
          store.index(INDEX_GID);
          store.getObject(contactId).then((Object value) {
            ContactRecord record = new ContactRecord();
            record.fromDb(value);
            Contact contact = new ContactImpl.fromDb(record);
            controller.add(contact);
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

class ContactImpl extends Contact {
  ContactRecord _record;

  ContactImpl.fromDb(ContactRecord record) {
    _record = record;
  }

  String get gid => _record.gid;
  DateTime get created => _record.created;
  String get name => _record.name;
  String get emailAddress => _record.emailWithCase;
  String get imageUri => _record.imageUri;
}
