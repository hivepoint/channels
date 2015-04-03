library group_tile;

import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:chnls_core/chnls_core.dart';
import "../core/core_ui.dart";
import "user_icon.dart";

@CustomTag('group-tile')
class GroupTile extends PolymerElement {
    GroupTile.created() : super.created();

    static GroupTile _lastOpenedGroup;
    
    @observable String groupTitle = "";
    @observable String groupColor = "white";
    
    Group group;
    
    DivElement _usersPanel;
    
    void attached() {
        super.attached();
        _usersPanel = shadowRoot.querySelector("#usersPanel");
        
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
        refreshUsers();
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
    
    void refreshUsers() {
        _usersPanel.children.clear();
        List<Contact> contacts = [];
        contacts.add(new SimpleContact("1", "kduffie@hivepoint.com", "Kingston Duffie"));
        contacts.add(new SimpleContact("2", "carl@hivepoint.com", "Carl Hubbard"));
        contacts.add(new SimpleContact("3", "preet@hivepoint.com", "Preet Shihn"));
        
        for (Contact c in contacts) {
            var icon = new Element.tag("user-icon") as UserIcon;
            icon.contact = c;
            icon.style.marginRight = "5px";
            _usersPanel.append(icon);
        }
    }
}