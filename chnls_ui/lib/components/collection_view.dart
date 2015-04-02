import 'dart:html';
import 'package:core_elements/core_header_panel.dart';
import 'package:polymer/polymer.dart';
import "../core/core_ui.dart";
import "group_tile.dart";

@CustomTag('collection-view')
class CollectionView extends PolymerElement {
    CollectionView.created() : super.created();
    
    DivElement _itemsPanel;
    DivElement _nonePanel;
    CoreHeaderPanel _container;
    
    List _subs = [];
    List<Collection> collections = [];
    
    void attached() {
        super.attached();
        _itemsPanel = shadowRoot.querySelector("#itemsPanel");
        _nonePanel = shadowRoot.querySelector("#nonePanel");
        _container = shadowRoot.querySelector("#container");
        
        _subs.add(window.onResize.listen((var e) {
            refreshPanelHeight();
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
    
    void onCreateChannel(var event) {
        collections.clear();
        collections.add(new Collection("Soccer team", "Scheduling soccer games", uiHelper.getRandomDarkColor()));
        collections.add(new Collection("Engineering", "Engineering discussions related to design and code", uiHelper.getRandomDarkColor()));
        collections.add(new Collection("Interesting", "All the interesting stuff you could find.", uiHelper.getRandomDarkColor()));
        collections.add(new Collection("System design", "System design is hot. Let's talk about it here.", uiHelper.getRandomDarkColor()));
        collections.add(new Collection("Whatever", "", uiHelper.getRandomDarkColor()));
        refresh();
    }
    
    void refresh() {
        _itemsPanel.children.clear();
        if (collections.isEmpty) {
            _nonePanel.style.display = "block";
        } else {
            _nonePanel.style.display = null;
            for (Collection c in collections) {
                addCollectionTile(c);
            }
        }
        refreshPanelHeight();
    }
    
    void addCollectionTile(Collection c) {
        var div = new Element.div();
        div..setAttribute("flex", "true")
           ..setAttribute("auto", "true")
           ..className = "groupTile";
        var tile = new Element.tag("group-tile") as GroupTile;
        tile.setAttribute("hero-id", "tile");
        tile.collection = c;
        div.append(tile);
        if (_itemsPanel.children.isEmpty) {
            _itemsPanel.append(div);
        } else {
            _itemsPanel.insertBefore(div, _itemsPanel.firstChild);
        }
    }
    
    void refreshPanelHeight() {
        bool setHeight = _container.offsetWidth >= 1200;
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