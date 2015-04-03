part of chnls_core;

class GroupsService extends Service {
  static final GroupsService _singleton = new GroupsService._internal();
  factory GroupsService() => _singleton;
  StreamController<Group> _groupAddedSource = new StreamController<Group>();
  Stream<Group> _groupAddedStream;
  GroupsCollection _store = new GroupsCollection();

  GroupsService._internal() {
    _groupAddedStream = _groupAddedSource.stream.asBroadcastStream();
  }

  void _onStop() {
    _groupAddedSource.close();
  }

  Stream<Group> groups() {
    StreamController<Group> controller = new StreamController<Group>();
    _store.listAll().listen((GroupRecord record) {
      Group group = new GroupImpl.fromDb(record);
      return group;      
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Future<Group> addGroup(String name, Iterable<Contact> people, String tileColor) {
    List<String> contactIds = new List<String>();
    if (people != null) {
      people.forEach((Contact contact) {
        contactIds.add(contact.gid);
      });
    }
    return _store.add(name, contactIds, tileColor).then((record) {
      Group group = new GroupImpl.fromDb(record);
      _groupAddedSource.add(group);
      return group;
    });
  }

  Stream<Group> onNewGroup() {
    return _groupAddedStream;
  }
  
  Future deleteAll() {
    return _store.removeAll();
  }
}

class GroupImpl extends Group {
  GroupRecord _record;
  ContactsService contactsService = new ContactsService();
  
  GroupImpl.fromDb(GroupRecord record) {
    _record = record; 
    if (_record.contactIds == null) {
      _record.contactIds = new Set<String>();
    }
  }
  
  String get gid => _record.gid;
  DateTime get created => _record.created;
  DateTime get lastUpdated => _record.lastUpdated;
  String get name => _record.name;
  String get tileColor => _record.tileColor;

  Future setTileColor(String value) {
    GroupsCollection collection = new GroupsCollection();
    return collection.setTileColor(_record, value).then((GroupRecord revisedRecord) {
      _record = revisedRecord;
    });
  }
  
  Stream<Contact> get people {
    return contactsService.getContactsById(_record.contactIds);
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
