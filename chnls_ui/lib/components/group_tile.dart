library group_tile;

import 'dart:async';
import 'package:polymer/polymer.dart';
import "../core/core_ui.dart";

@CustomTag('group-tile')
class GroupTile extends PolymerElement {
    GroupTile.created() : super.created();

    static GroupTile _lastOpenedGroup;
    
    @observable String groupTitle = "";
    @observable String groupColor = "white";
    
    Collection collection;
    
    void attached() {
        super.attached();
        refresh();
        new Future(() {
            var shell = shadowRoot.querySelector("#shell");
            shell.style..opacity = "1"
                       ..transform = "none";
        });
    }
    
    void refresh() {
        if (collection == null) {
            groupColor = "white";
            groupTitle = "";
        } else {
            groupColor = collection.color;
            groupTitle = collection.name;
        }
    }
    
    void onOpenGroup(var event) {
        if (collection != null) {
            if (_lastOpenedGroup != null) {
                _lastOpenedGroup.attributes.remove("hero");
            }
            setAttribute("hero", "true");
            _lastOpenedGroup = this;
            router.openGroupPage(collection);
        }
    }
    
}