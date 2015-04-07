part of chnls_core;

class ContactService extends Service {
  static final ContactService _singleton = new ContactService._internal();
  factory ContactService() => _singleton;
  StreamController<Contact> _contactAddedSource = new StreamController<Contact>();
  Stream<Contact> _contactAddedStream;
  ContactsCollection _store = new ContactsCollection();

  ContactService._internal() {
    _contactAddedStream = _contactAddedSource.stream.asBroadcastStream();
  }

  void _onStop() {
    _contactAddedSource.close();
  }

  Stream<Contact> contacts() {
    StreamController<Contact> controller = new StreamController<Contact>();
    _store.listAll().listen((ContactRecord record) {
      Contact contact = new ContactImpl.fromDb(record);
      controller.add(contact);
      return contact;
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Stream<Contact> _getContactsById(Iterable<String> contactIds) {
    StreamController<Contact> controller = new StreamController<Contact>();
    if (contactIds == null) {
      controller.close();
    } else {
      _store.listByIds(contactIds).listen((ContactRecord record) {
        ContactImpl contact = new ContactImpl.fromDb(record);
        controller.add(contact);
      }).onDone(() {
        controller.close();
      });
    }
    return controller.stream;
  }

  Future<Contact> addContact(bool isMe, String emailAddress, String name, String imageUri) {
    return _store.add(isMe, emailAddress, name, imageUri).then((ContactRecord record) {
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

  Future<Contact> getContactByEmail(String emailAddress) {
    return new ContactsCollection().getByEmail(emailAddress).then((ContactRecord record) {
      return new ContactImpl.fromDb(record);
    });
  }

  Stream<Contact> getContactsByEmail(Iterable<String> emailAddresses) {
    var controller = new StreamController<Contact>();
    if (emailAddresses == null) {
      controller.close();
    } else {
      new ContactsCollection().listByEmailAddresses(emailAddresses).listen((ContactRecord record) => controller.add(new ContactImpl.fromDb(record))).onDone(() {
        controller.close();
      });
    }
    return controller.stream;
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
  bool get isMe => _record.isMe;
}
