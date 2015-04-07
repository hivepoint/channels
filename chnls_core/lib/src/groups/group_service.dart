part of chnls_core;

class GroupService extends Service {
  static final GroupService _singleton = new GroupService._internal();
  factory GroupService() => _singleton;
  StreamController<Group> _groupAddedSource = new StreamController<Group>();
  Stream<Group> _groupAddedStream;
  GroupsCollection _store = new GroupsCollection();

  GroupService._internal() {
    _groupAddedStream = _groupAddedSource.stream.asBroadcastStream();
  }

  void _onStop() {
    _groupAddedSource.close();
  }

  Stream<Group> groups() {
    StreamController<Group> controller = new StreamController<Group>();
    _store.listAll().listen((GroupRecord record) {
      Group group = new GroupImpl._fromDb(record);
      controller.add(group);
      return group;
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Future<Group> addGroup(String name, Stream<Contact> people, String tileColor) {
    List<String> contactIds = new List<String>();
    return people.forEach((Contact contact) => contactIds.add(contact.gid))
        .then((_) => _store.add(name, contactIds, tileColor)).then((record) {
      Group group = new GroupImpl._fromDb(record);
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

  Future<Group> _getById(String groupId) {
    return _store.getById(groupId).then((record) {
      var group = new GroupImpl._fromDb(record);
      return group;
    });
  }
}

class GroupImpl extends Group {
  GroupRecord _record;
  var contactService = new ContactService();

  GroupImpl._fromDb(GroupRecord record) {
    _record = record;
    if (_record.contactIds == null) {
      _record.contactIds = new List<String>();
    }
  }

  String get gid => _record.gid;
  DateTime get created => _record.created;
  DateTime get lastUpdated => _record.lastUpdated;
  String get name => _record.name;
  String get tileColor => _record.tileColor;

  Future<Group> setTileColor(String value) {
    GroupsCollection collection = new GroupsCollection();
    return collection.setTileColor(_record.gid, value).then((GroupRecord revisedRecord) {
      return new GroupImpl._fromDb(revisedRecord);
    });
  }

  Stream<Contact> get people => new ContactService()._getContactsById(_record.contactIds);

  Stream<Conversation> get conversations => new ConversationService()._conversationsByGroup(_record.gid);

  Future<Conversation> createConversation(String subject) => new ConversationService()._addConversation(_record.gid, subject);
}
