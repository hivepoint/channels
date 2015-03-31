import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('feed-view')
class FeedView extends PolymerElement {
    @observable bool composeShowing = false;
    
    DivElement _itemsPanel;
    
    FeedView.created() : super.created();
    
    void attached() {
        _itemsPanel = shadowRoot.querySelector("#itemsPanel");
        refresh();
    }
    
    void refresh() {
        _itemsPanel.children.clear();
    }
    
    void onNewMessage(MouseEvent e) {
        composeShowing = !composeShowing;
    }
    
}