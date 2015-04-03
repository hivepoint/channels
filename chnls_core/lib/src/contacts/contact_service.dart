part of chnls_core;

class ContactsService extends Service {
  static final ContactsService _singleton = new ContactsService._internal();
  factory ContactsService() => _singleton;
  StreamController<Contact> _contactAddedSource = new StreamController<Contact>();
  Stream<Contact> _contactAddedStream;
  ContactsCollection _store = new ContactsCollection();

  ContactsService._internal() {
    _contactAddedStream = _contactAddedSource.stream.asBroadcastStream();
  }
  
  void _onStop() {
    _contactAddedSource.close();
  }
  
  Stream<Contact> contacts() {
    StreamController<Contact> controller = new StreamController<Contact>();
    _store.listAll().listen((ContactRecord record) {
      Contact contact = new ContactImpl.fromDb(record);
      return contact;      
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Stream<Contact> getContactsById(Set<String> contactIds) {
    StreamController<Contact> controller = new StreamController<Contact>();
    _store.listByIds(contactIds).listen((ContactRecord record) {
      ContactImpl contact = new ContactImpl.fromDb(record);
      controller.add(contact);
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }
  
  Future<Contact> addContact(String emailAddress, String name, String imageUri) {
    return _store.add(emailAddress, name, imageUri).then((ContactRecord record) {
      Contact contact = new ContactImpl.fromDb(record);
     _contactAddedSource.add(contact);
     return contact;
    });
  }
  
  Future deleteAll() {
    return _store.removeAll();
  }
  
  Stream<Contact> onNewContact() {
    return _contactAddedStream;
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
