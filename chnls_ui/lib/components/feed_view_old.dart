import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:chnls_core/chnls_core.dart';

@CustomTag('feed-view-old')
class FeedViewOld extends PolymerElement {
    @observable bool composeShowing = false;
    
    DivElement _itemsPanel;
    StreamSubscription<Message> _subscription = null;
    var _newMessageSub = null;
    
    FeedViewOld.created() : super.created();
    
    void attached() {
        super.attached();
        _itemsPanel = shadowRoot.querySelector("#itemsPanel");
//        ComposeDialog dlg =  shadowRoot.querySelector("#compose");
//        _newMessageSub = dlg.onMessageSent.listen((Message newMessage) {
//            MessageItem item = (new Element.tag("message-item") as MessageItem);
//            item.message = newMessage;
//            item.animateIn = true;
//            if (_itemsPanel.children.isEmpty) {
//                _itemsPanel.append(item);
//            } else {
//                _itemsPanel.insertBefore(item, _itemsPanel.children.first);
//            }
//        });
        
        refresh();
    }
    
    void detached() {
        if (_subscription != null) {
            _subscription.cancel();
            _subscription = null;
        }
        if (_newMessageSub != null) {
            _newMessageSub.cancel();
            _newMessageSub = null;
        }
        super.detached();
    }
    
    void refresh() {
        _itemsPanel.children.clear();
//        MessageService service = new MessageService();
//        _subscription = service.getMessages().listen((Message msg) {
//            MessageItem item = (new Element.tag("message-item") as MessageItem);
//            item.message = msg;
//            _itemsPanel.append(item);
//        });
        _subscription.onDone(() {
            _subscription = null;
        });
    }
    
    void onNewMessage(MouseEvent e) {
        composeShowing = !composeShowing;
    }
    
    void onNewMessageSent(Message newMessage) {
//        window.alert("New message: ${newMessage.body}");
    }
    
}