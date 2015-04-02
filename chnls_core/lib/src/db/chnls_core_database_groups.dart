part of chnls_core;

class GroupsCollection extends DatabaseCollection {
  static final GroupsCollection _singleton = new GroupsCollection._internal();
  factory GroupsCollection() => _singleton;
  static const String GROUPS_STORE = "groups";

  GroupsCollection._internal() : super(GROUPS_STORE);
  
  static void _initialize(idb.Database db) {
    if (db.objectStoreNames.contains(GROUPS_STORE)) {
      db.deleteObjectStore(GROUPS_STORE);
    }
    idb.ObjectStore store = db.createObjectStore(GROUPS_STORE, autoIncrement: true);
    store.createIndex('gid', 'gid', unique: true);
  }
    
  Stream<Group> listAll() {
    StreamController<Group> controller = new StreamController<Group>();
    _transaction().then((store) {
      store.openCursor(autoAdvance:true).listen((idb.CursorWithValue value) {
        GroupRecord record = new GroupRecord();
        record.fromDb(value.key, value.value);
        Group group = new GroupImpl.fromDb(record);
        controller.add(group);
      }).onDone(() {
        controller.close();
      });
    });
    return controller.stream;
  }

}

@export
class GroupRecord extends DatabaseRecord with WithGuid {
  @export String name;
  @export DateTime created;
  @export Set<String> contactIds = new Set<String>(); 
  
  GroupRecord();
  GroupRecord.fromFields(String gid, String this.name, DateTime this.created) {
    this.gid = gid;
  }
}

class GroupImpl extends Group {
  GroupRecord _record;
  
  GroupImpl.fromDb(GroupRecord record) {
    _record = record; 
  }
  
  String get gid => _record.gid;
  DateTime get created => _record.created;
  String get name => _record.name;

  Future<Set<Contact>> get people {
    ContactsService contactService = new ContactsService();
    return contactService.getContactsById(_record.contactIds).toSet().then((contacts) => contacts);
  }
  Stream<Conversation> get conversations {
    return new Stream<Conversation>.fromIterable(new List<Conversation>());
  }

  Stream<Conversation> onNewConversation() {
    StreamController<Conversation> controller = new StreamController<Conversation>();
    return controller.stream;
  }
  
  Future<Conversation> createConversation(String topic, Set<String> contacts) {
    throw new UnimplementedError("To do");
  }

}