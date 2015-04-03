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
  
  Stream<Contact> getContactsById(Set<String> contactIds) {
    return _store.listByIds(contactIds);
  }
  
  Future<Contact> addContact(String emailAddress, String name, String imageUri) {
    ContactRecord record = new ContactRecord.fromFields(generateUid(), emailAddress, name, new DateTime.now(), imageUri);
    return _store.insert(record).then((_) {
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

