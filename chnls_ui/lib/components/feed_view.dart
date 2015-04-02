import 'package:polymer/polymer.dart';
import "../core/core_ui.dart";

@CustomTag("feed-view")
class FeedView extends PolymerElement {
    FeedView.created() : super.created();
    
    @observable String groupName = "";
    @observable String groupDescription = "";
    @observable String groupColor = "white";
    
    Collection _collection;
    
    set collection(Collection c) {
        _collection = c;
        if (hasBeenAttached) {
            refresh();
        }
    }
    
    void attached() {
        super.attached();
        refresh();
    }
    
    void detached() {
        super.detached();
    }
    
    void refresh() {
        if (_collection == null) {
            groupColor = "white";
            groupName = "";
            groupDescription = "";
        } else {
            groupColor = _collection.color;
            groupName = _collection.name;
            groupDescription = _collection.description;
        }
    }
    
    void onBackClick(var event) {
        router.openCollectionsPage();
    }
}