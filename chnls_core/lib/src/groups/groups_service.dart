part of chnls_core;

class GroupsService extends Service {
  static final GroupsService _singleton = new GroupsService._internal();
  factory GroupsService() => _singleton;
  StreamController<Group> _groupAddedSource = new StreamController<Group>();
  Stream<Group> _groupAddedStream;

  GroupsService._internal() {
    _groupAddedStream = _groupAddedSource.stream.asBroadcastStream();
  }

  void _onStop() {
    _groupAddedSource.close();
  }

  Stream<Group> groups() {
    GroupsCollection groupStore = new GroupsCollection();
    return groupStore.listAll();
  }

  Future<Group> addGroup(String name, Iterable<Contact> people, String tileColor) {
    GroupsCollection groupStore = new GroupsCollection();
    if (people == null) {
      people = new Set<Contact>();
    }
    GroupRecord record = new GroupRecord.fromFields(generateUid(), name, new DateTime.now(), tileColor);
    people.forEach((person) {
      record.contactIds.add(person.gid);      
    });
    return groupStore.insert(record).then((_) {
      Group group = new GroupImpl.fromDb(record);
      _groupAddedSource.add(group);
      return group;
    });
  }

  Stream<Group> onNewGroup() {
    return _groupAddedStream;
  }
  
  Future deleteAll() {
    GroupsCollection store = new GroupsCollection();
    return store.removeAll();
  }
}
