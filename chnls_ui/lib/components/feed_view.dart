import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:chnls_core/chnls_core.dart';

@CustomTag('feed-view')
class FeedView extends PolymerElement {
    @observable bool composeShowing = false;
    
    DivElement _itemsPanel;
    StreamSubscription<Message> _subscription = null;
    
    FeedView.created() : super.created();
    
    void attached() {
        _itemsPanel = shadowRoot.querySelector("#itemsPanel");
        refresh();
    }
    
    void detached() {
        if (_subscription != null) {
            _subscription.cancel();
            _subscription = null;
        }
    }
    
    void refresh() {
        _itemsPanel.children.clear();
        MessageService service = new MessageService();
        _subscription = service.getMessages().listen((Message msg) {
            print("message received: ${msg.body}");
        });
        _subscription.onDone(() {
            print("subscription done");
            _subscription = null;
        });
    }
    
    void onNewMessage(MouseEvent e) {
        composeShowing = !composeShowing;
    }
    
}