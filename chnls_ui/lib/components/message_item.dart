import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:chnls_core/chnls_core.dart';

@CustomTag('message-item')
class MessageItem extends PolymerElement {
    @observable String sender = "";
    @observable String messageBody = "";
    
    Message message;
    bool animateIn = false;
    
    DivElement _container;
    
    MessageItem.created() : super.created();
    
    void attached() {
        if (message == null) {
            sender = "";
            messageBody = "";
        } else {
            sender = "Johny Greenwood";
            messageBody = message.body;
        }
        
        _container = shadowRoot.querySelector("#msgItemContainer");
        
        if (!animateIn) {
            _container.style.transform = "none";
            _container.style.opacity = "1";
        } else {
            _container.className = "itemTransition";
            new Future(() {
                _container.style.transform = "none";
                _container.style.opacity = "1";
            });
        }
    }
    
}