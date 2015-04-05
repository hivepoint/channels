part of chnls_core;

class AccountService extends Service {
  static final AccountService _singleton = new AccountService._internal();
  factory AccountService() => _singleton;
  StreamController<LinkedAccount> _accountAddedSource = new StreamController<LinkedAccount>();
  Stream<LinkedAccount> _accountAddedStream;
  LinkedAccountsCollection _store = new LinkedAccountsCollection();

  AccountService._internal() {
    _accountAddedStream = _accountAddedSource.stream.asBroadcastStream();
  }

  void _onStop() {
    _accountAddedSource.close();
  }

  Stream<LinkedAccount> linkedAccounts() {
    StreamController<LinkedAccount> controller = new StreamController<LinkedAccount>();
    _store.listAll().listen((LinkedAccountRecord record) {
      LinkedAccount account = new LinkedAccountImpl._fromDb(record);
      controller.add(account);
      return account;
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Future<LinkedAccount> addLinkedAccount(
      String address, String name, LinkedAccountType type) {
    return _store.add(address, name, type).then((record) {
      LinkedAccount account = new LinkedAccountImpl._fromDb(record);
      _accountAddedSource.add(account);
      return account;
    });
  }

  Stream<LinkedAccount> onNewLinkedAccount() {
    return _accountAddedStream;
  }

  Future deleteAll() {
    return _store.removeAll();
  }

  Future<LinkedAccount> _linkedAccountById(String linkedAccountId) {
    if (linkedAccountId == null) {
      return new Future<LinkedAccount>(null);
    }
    return _store.getById(linkedAccountId).then((record) {
      return new LinkedAccountImpl._fromDb(record);
    });
  }
}

class LinkedAccountImpl extends LinkedAccount {
  LinkedAccountRecord _record;

  LinkedAccountImpl._fromDb(LinkedAccountRecord record) {
    _record = record;
  }

  String get gid => _record.gid;
  String get address  => _record.address;
  String get name  => _record.name;
  LinkedAccountType get type => _record.type;

//  Future<LinkedAccount> setTileColor(String value) {
//    LinkedAccountsCollection collection = new LinkedAccountsCollection();
//    return collection
//        .setTileColor(_record.gid, value)
//        .then((LinkedAccountRecord revisedRecord) {
//      return new LinkedAccountImpl._fromDb(revisedRecord);
//    });
//  }

}
