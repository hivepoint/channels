part of chnls_core;

class DatabaseService extends Service {
  static final DatabaseService _singleton = new DatabaseService._internal();
  factory DatabaseService() => _singleton;
  idb.IdbFactory _idb;

  DatabaseService._internal() {
    _idb = window.indexedDB;
  }
  
  Future<idb.Database> open() {
    return _idb.open("chnls", version: 5, onUpgradeNeeded: _initialize);
  }
  
  void _initialize(idb.VersionChangeEvent e) {
    idb.Database db = (e.target as idb.Request).result;
    GroupsCollection._initialize(db);
    ContactsCollection._initialize(db);
    ConversationsCollection._initialize(db);
    MessagesCollection._initialize(db);
  }
  
  void _onStop() {
  }
}