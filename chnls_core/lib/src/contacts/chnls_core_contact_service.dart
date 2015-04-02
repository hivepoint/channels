part of chnls_core;

class ContactsService extends Service {
  static final ContactsService _singleton = new ContactsService._internal();
  factory ContactsService() => _singleton;
  StreamController<Contact> _contactAddedSource = new StreamController<Contact>();
  Stream<Contact> _contactAddedStream;

  ContactsService._internal() {
    _contactAddedStream = _contactAddedSource.stream.asBroadcastStream();
  }
  
  void _onStop() {
    _contactAddedSource.close();
  }
  
  Stream<Contact> getContactsById(Set<String> contactIds) {
    var contacts = new List<Contact>();
    return new Stream<Contact>.fromIterable(contacts);  
  }
  
  Future<Contact> createContact(String emailAddress, String name) {
    return new Future.sync(() => new SimpleContact(generateUid(), emailAddress, name)).then((contact) {
      _contactAddedSource.add(contact);
    });
  }
  
  Stream<Contact> onNewContact() {
    return _contactAddedStream;
  }
}

