import 'dart:html';
import 'package:core_elements/core_header_panel.dart';
import 'package:polymer/polymer.dart';
import 'package:chnls_core/chnls_core.dart';
import "../core/core_ui.dart";
import "group_tile.dart";
import 'dialogs/create_group_dialog.dart';

@CustomTag('collection-view')
class CollectionView extends PolymerElement {
    CollectionView.created() : super.created();
    
    @observable bool showCreateDialog = false;
    
    DivElement _itemsPanel;
    DivElement _nonePanel;
    CoreHeaderPanel _container;
    
    List _subs = [];
    List<Group> _groups = [];
    
    void attached() {
        super.attached();
        _itemsPanel = shadowRoot.querySelector("#itemsPanel");
        _nonePanel = shadowRoot.querySelector("#nonePanel");
        _container = shadowRoot.querySelector("#container");
        
        _subs.add(window.onResize.listen((var e) {
            refreshPanelHeight();
        }));
        
        CreateGroupDialog dlg =  shadowRoot.querySelector("#createGroupDialog");
        _subs.add(dlg.onGroupCreated.listen((Group g) {
            _groups.add(g);
            addGroupTile(g);
            refreshLayout();
        }));
        
        refresh();
    }
    
    void detached() {
        for (var s in _subs) {
            s.clear();
        }
        _subs.clear();
        super.detached();
    }
    
    void onMenuClick(var event) {
        uiHelper.navOpen = true;
    }
    
    void onCreateGroup(var event) {
        showCreateDialog = !showCreateDialog;
    }
    
    void refresh() {
        _groups.clear();
        
        GroupsService service = new GroupsService();
        service.groups().listen((Group group) {
            _groups.add(group);
        }).onDone(() {
            refreshView();
        });
    }
    
    void refreshView() {
        _itemsPanel.children.clear();
        for (Group g in _groups) {
            addGroupTile(g);
        }
        refreshLayout();
    }
    
    void refreshLayout() {
        if (_groups.isEmpty) {
            _nonePanel.style.display = "block";
        } else {
            _nonePanel.style.display = null;
        }
        refreshPanelHeight();
    }
    
    void addGroupTile(Group group) {
        var div = new Element.div();
        div..setAttribute("flex", "true")
           ..setAttribute("auto", "true")
           ..className = "groupTile";
        var tile = new Element.tag("group-tile") as GroupTile;
        tile.setAttribute("hero-id", "tile");
        tile.group = group;
        div.append(tile);
        if (_itemsPanel.children.isEmpty) {
            _itemsPanel.append(div);
        } else {
            _itemsPanel.insertBefore(div, _itemsPanel.firstChild);
        }
    }
    
    void refreshPanelHeight() {
        bool setHeight = _container.offsetWidth >= 1200 && _itemsPanel.children.length > 0;
        if (!setHeight) {
            setHeight = _itemsPanel.children.length > 1;
        }
        if (setHeight) {
            int mh = _container.offsetHeight - 110;
            if (mh > 0) {
                _itemsPanel.style.minHeight = '${mh}px';
            } else {
                _itemsPanel.style.minHeight = null;
            }
        } else {
            _itemsPanel.style.minHeight = null;
        }
    }
        
}