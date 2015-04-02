part of chnls_core;

abstract class DatabaseCollection {
  String collectionName;
  
  Future insert(DatabaseRecord record) {
    return _transaction(rw: true).then((store) {
      store.add(record.toDb());
    });
  }
  
  DatabaseCollection(String this.collectionName);
  
  Future<idb.ObjectStore> _transaction({rw: false}) {
    DatabaseService dbs = new DatabaseService();
    return dbs.open()
        .then((db) {
      var t;
      if (rw) {
        t = db.transaction(collectionName, 'readwrite');
      } else {
        t = db.transaction(collectionName, 'readonly');
      }
      return t.objectStore(collectionName);
    });
  }
  
  Future removeAll() {
    return _transaction(rw:true).then((store) {
      store.clear();
    });
  }

}

abstract class DatabaseRecord extends Object with Exportable  {
    DatabaseRecord();

    void fromDb(Object key, Object record) {
      initFromMap(record);
    }

    Map toDb() {
      return this.toMap();
    }
}