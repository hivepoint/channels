part of chnls_core;

const String INDEX_GID = "gid";

typedef Object DatabaseRecordUpdater(Object recordValue);

abstract class DatabaseCollection {
  String collectionName;

  Future insert(DatabaseRecord record) {
    return _transaction(rw: true).then((idb.ObjectStore store) {
      return store.put(record.toDb());
    });
  }

  DatabaseCollection(String this.collectionName);

  Future<idb.ObjectStore> _transaction({rw: false}) {
    DatabaseService dbs = new DatabaseService();
    return dbs.open().then((db) {
      idb.Transaction t;
      if (rw) {
        t = db.transaction(collectionName, 'readwrite');
      } else {
        t = db.transaction(collectionName, 'readonly');
      }
      idb.ObjectStore store = t.objectStore(collectionName);
      return store;
    });
  }

  Future removeAll() {
    return _transaction(rw: true).then((store) {
      store.clear();
    });
  }
  
  Future fetchAndUpdate(String id, DatabaseRecordUpdater updater) {
    return _transaction(rw: true).then((idb.ObjectStore store) {
      return store.index(INDEX_GID).get(id).then((value) {
        return store.put(updater(value));
      });
    });
  }
}

abstract class DatabaseRecord extends Object with Exportable {
  DatabaseRecord();

  void fromDb(Object record) {
    initFromMap(record);
  }

  Map toDb() {
    return this.toMap();
  }
  
}
