part of chnls_core;

class AccountService extends Service {
  static final AccountService _singleton = new AccountService._internal();
  factory AccountService() => _singleton;
  StreamController<LinkedAccount> _accountAddedSource = new StreamController<LinkedAccount>();
  Stream<LinkedAccount> _accountAddedStream;
  LinkedAccountsCollection _store = new LinkedAccountsCollection();
  Map<String, GmailClient> _gmailClientsByEmail = new HashMap<String, GmailClient>();

  AccountService._internal() {
    _accountAddedStream = _accountAddedSource.stream.asBroadcastStream();
  }

  void _onStop() {
    _accountAddedSource.close();
  }

  Stream<LinkedAccount> linkedAccounts() {
    StreamController<LinkedAccount> controller = new StreamController<LinkedAccount>();
    _store.listAll().listen((LinkedAccountRecord record) {
      LinkedAccount account = new LinkedAccountImpl.fromDb(record);
      controller.add(account);
      return account;
    }).onDone(() {
      controller.close();
    });
    return controller.stream;
  }

  Future<LinkedAccount> addLinkedAccount(String address, String name, LinkedAccountType type) {
    return _store.add(address, name, type).then((record) {
      LinkedAccount account = new LinkedAccountImpl.fromDb(record);
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
  
  Future<DeliverableMessage> deliverEmail(DeliverableMessage message) {
      return getLinkedAccountByEmail(message.fromAddress)
          .then((LinkedAccount linkedAccount) => linkedAccount.deliverEmail(message));
  }
  
  Future<LinkedAccount> getLinkedAccountByEmail(String emailAddress) {
      return _store.getByTypeAndAddress(LinkedAccountType.GMAIL, emailAddress)
          .then((LinkedAccountRecord record) => new LinkedAccountImpl.fromDb(record));    
  }

  Future<LinkedAccount> _linkedAccountById(String linkedAccountId) {
    if (linkedAccountId == null) {
      return new Future<LinkedAccount>(null);
    }
    return _store.getById(linkedAccountId).then((record) {
      return new LinkedAccountImpl.fromDb(record);
    });
  }

  Future<GmailClient> getGmailClient(String emailAddress) {
    return _getOrCreateGmailAccount(emailAddress).then((LinkedAccount linkedAccount) {
      if (_gmailClientsByEmail.containsKey(emailAddress.toLowerCase())) {
        return new Future<GmailClient>(() => _gmailClientsByEmail[emailAddress.toLowerCase()]);
      } else {
        return new GoogleAuth().authorizedClient().then((auth.AutoRefreshingAuthClient authClient) {
          GmailClient client = new GmailClient.withAuthClient(authClient, linkedAccount.gid);
          _gmailClientsByEmail.putIfAbsent(emailAddress.toLowerCase(), () => client);
          return client;
        });
      }
    });
        
  }

  Future<LinkedAccount> _getOrCreateGmailAccount(String emailAddress) {
    return _store.getByTypeAndAddress(LinkedAccountType.GMAIL, emailAddress).then((record) {
      return new LinkedAccountImpl.fromDb(record);
    });
  }
}

class LinkedAccountImpl extends LinkedAccount {
  LinkedAccountRecord _record;

  LinkedAccountImpl.fromDb(LinkedAccountRecord record) {
    _record = record;
  }

  String get gid => _record.gid;
  String get address => _record.address;
  String get name => _record.name;
  LinkedAccountType get type => _record.type;

  Future<DeliverableMessage> deliverEmail(DeliverableMessage message) {
    switch(type) {
      case LinkedAccountType.GMAIL:
        return new AccountService().getGmailClient(address)
            .then((GmailClient gmailClient) => gmailClient.sendEmail(message));
      default:
        throw new UnimplementedError("Cannot deliver email for this type of linked account");
    }
  }
}
