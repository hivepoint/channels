import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:chnls_core/chnls_core.dart';
import 'message_item.dart';
import 'dialogs/compose_dialog.dart';

@CustomTag('feed-view')
class FeedView extends PolymerElement {
    @observable bool composeShowing = false;
    
    DivElement _itemsPanel;
    StreamSubscription<MessageV0> _subscription = null;
    var _newMessageSub = null;
    
    FeedView.created() : super.created();
    
    void attached() {
        _itemsPanel = shadowRoot.querySelector("#itemsPanel");
        ComposeDialog dlg =  shadowRoot.querySelector("#compose");
        _newMessageSub = dlg.onMessageSent.listen((MessageV0 newMessage) {
            MessageItem item = (new Element.tag("message-item") as MessageItem);
            item.message = newMessage;
            item.animateIn = true;
            if (_itemsPanel.children.isEmpty) {
                _itemsPanel.append(item);
            } else {
                _itemsPanel.insertBefore(item, _itemsPanel.children.first);
            }
        });
        
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
    }
    
    void refresh() {
        _itemsPanel.children.clear();
        MessageService service = new MessageService();
        _subscription = service.getMessages().listen((MessageV0 msg) {
            MessageItem item = (new Element.tag("message-item") as MessageItem);
            item.message = msg;
            _itemsPanel.append(item);
        });
        _subscription.onDone(() {
            _subscription = null;
        });
    }
    
    void onNewMessage(MouseEvent e) {
        composeShowing = !composeShowing;
    }
    
    void onNewMessageSent(MessageV0 newMessage) {
        window.alert("New message: ${newMessage.body}");
    }
    
}