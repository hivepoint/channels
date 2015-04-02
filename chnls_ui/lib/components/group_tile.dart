library group_tile;

import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:chnls_core/chnls_core.dart';
import "../core/core_ui.dart";

@CustomTag('group-tile')
class GroupTile extends PolymerElement {
    GroupTile.created() : super.created();

    static GroupTile _lastOpenedGroup;
    
    @observable String groupTitle = "";
    @observable String groupColor = "white";
    
    Group group;
    
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
        if (group == null) {
            groupColor = "white";
            groupTitle = "";
        } else {
            groupColor = uiHelper.getRandomDarkColor();
            groupTitle = group.name;
        }
    }
    
    void onOpenGroup(var event) {
        if (group != null) {
            if (_lastOpenedGroup != null) {
                _lastOpenedGroup.attributes.remove("hero");
            }
            setAttribute("hero", "true");
            _lastOpenedGroup = this;
            router.openGroupPage(group);
        }
    }
    
}