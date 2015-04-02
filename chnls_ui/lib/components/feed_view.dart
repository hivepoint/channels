import 'package:polymer/polymer.dart';
import "../core/core_ui.dart";
import 'package:chnls_core/chnls_core.dart';

@CustomTag("feed-view")
class FeedView extends PolymerElement {
    FeedView.created() : super.created();
    
    @observable String groupName = "";
    @observable String groupDescription = "";
    @observable String groupColor = "white";
    
    Group _group;
    
    set group(Group g) {
        _group = g;
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
        // TODO: scroll to top
        if (_group == null) {
            groupColor = "white";
            groupName = "";
            groupDescription = "";
        } else {
            groupColor = uiHelper.getRandomDarkColor();
            groupName = _group.name;
            groupDescription = "";
        }
    }
    
    void onBackClick(var event) {
        router.openCollectionsPage();
    }
}