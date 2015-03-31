part of chnls_core;

abstract class Message {
  String body;
}

class DbMessageV1 extends Object with Exportable implements Message {
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
class MessageService {
  static final MessageService _singleton = new MessageService._internal();
  factory MessageService() => _singleton;
  idb.IdbFactory _idb;
  static const String MESSAGES_STORE = "messages";
  
  
  MessageService._internal() {
      _idb = window.indexedDB;
  }
  
  Future<idb.ObjectStore> _messageTransaction({readWrite: false}) {
    return _idb.open("chnls_messages", version: 1, onUpgradeNeeded: _initializeMessages).then((db) {
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
  
  
  Stream<Message> getMessages() {
    StreamController<Message> source = new StreamController<Message>();
    _messageTransaction().then((store) {
      var cursor = store.openCursor(autoAdvance: true).asBroadcastStream();
      cursor.listen((c) {
        Message m = new DbMessageV1._fromDb(c.key, c.value);
        source.add(m);
      }, onDone: () => source.close());
    });
    return source.stream;
  }
  
  Future<Message> addMessage(String body) {
    DbMessageV1 message = new DbMessageV1.fromBody(body);
    return _messageTransaction(readWrite:true).then((store) {
      return store.add(message.toDb()).then((newKey) {
        message.key = newKey;
        return message;
      });
    });
  }
  
  Future clearAllMessages() {
    return _messageTransaction(readWrite:true).then((store) {
      return store.clear();
    });
  }
}

