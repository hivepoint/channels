part of chnls_core;

abstract class MessageV0 {
  String body;
}

abstract class MessageV2 extends MessageV0 {
  DateTime sent;
  String messageIdHeader;
  String sender;
  String from;
  List<String> to;
  List<String> cc;
  String subject;
  String preamble;
}

@export
class DbMessageV1 extends Object with Exportable implements MessageV0 {
  Object key;
  @export String body;

  DbMessageV1();
  DbMessageV1.fromBody(String this.body);

  factory DbMessageV1._fromDb(Object key, Object record) {
    DbMessageV1 result = new DbMessageV1();
    result.initFromMap(record);
    result.key = key;
    return result;
  }

  Map toDb() {
    return this.toMap();
  }
}

@export
class DbGmailMessageV2 extends Object with Exportable implements MessageV2 {
  Object key;
  @export String gmailMessageId;
  @export String body;
  @export DateTime sent;
  @export String messageIdHeader;
  @export String sender;
  @export String from;
  @export List<String> to;
  @export List<String> cc;
  @export String subject;
  @export String preamble;
  
  DbGmailMessageV2();
  DbGmailMessageV2.fromFromAndBody(String this.from, String this.body);

  factory DbGmailMessageV2._fromDb(Object key, Object record) {
    var result = new DbGmailMessageV2();
    result.initFromMap(record);
    result.key = key;
    return result;
  }

  Map toDb() {
    return this.toMap();
  }
}

class MessageService {
  static final MessageService _singleton = new MessageService._internal();
  factory MessageService() => _singleton;
  idb.IdbFactory _idb;
  static const String MESSAGES_STORE = "messages";

  MessageService._internal() {
    _idb = window.indexedDB;
  }

  Future<idb.ObjectStore> _messageTransaction({readWrite: false}) {
    return _idb
        .open("chnls_messages_v0",
            version: 1, onUpgradeNeeded: _initializeMessages)
        .then((db) {
      var t;
      if (readWrite) {
        t = db.transaction(MESSAGES_STORE, 'readwrite');
      } else {
        t = db.transaction(MESSAGES_STORE, 'readonly');
      }
      return t.objectStore(MESSAGES_STORE);
    });
  }

  void _initializeMessages(idb.VersionChangeEvent e) {
    idb.Database db = (e.target as idb.Request).result;
    db.createObjectStore(MESSAGES_STORE, autoIncrement: true);
  }

  Stream<MessageV0> getMessages() {
    StreamController<MessageV0> source = new StreamController<MessageV0>();
    _messageTransaction().then((store) {
      var cursor = store.openCursor(autoAdvance: true);
      cursor.listen((c) {
        MessageV0 m = new DbGmailMessageV2._fromDb(c.key, c.value);
        source.add(m);
      }, onDone: () => source.close());
    });
    return source.stream;
  }

  Future<MessageV0> addMessage(String from, String body) {
    var message = new DbGmailMessageV2.fromFromAndBody(from, body);
    var completer = new Completer<MessageV0>();
    _messageTransaction(readWrite: true).then((store) {
      store.add(message.toDb()).then((newKey) {
        message.key = newKey;
        completer.complete(message);
      });
    });
    return completer.future;
  }

  Future clearAllMessages() {
    return _messageTransaction(readWrite: true).then((store) {
      store.clear();
    });
  }
}
