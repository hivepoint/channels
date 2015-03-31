import 'dart:html';
import 'package:chnls_core/chnls_core.dart';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_autogrow_textarea.dart';
import 'package:paper_elements/paper_input_decorator.dart';
import 'package:paper_elements/paper_toast.dart';

@CustomTag('compose-dialog')
class ComposeDialog extends PolymerElement {
    @published String heading = null;
    @published bool showing = false;
    
    PaperAutogrowTextarea _textContainer;
    TextAreaElement _text;
    PaperInputDecorator _decorator;
    PaperToast _toast;
    
    ComposeDialog.created() : super.created();
    
    void attached() {
        _textContainer = shadowRoot.querySelector("#textContainer");
        _text = shadowRoot.querySelector("#text");
        _decorator = shadowRoot.querySelector("#composeDecorator");
        _toast = shadowRoot.querySelector("#sentToast");
    }
    
    void onSend(MouseEvent e) {
        String body = _text.value.trim();
        if (body.isEmpty) {
            _decorator.isInvalid = true;
        } else {
            _decorator.isInvalid = false;
            showing = false;
            MessageService service = new MessageService();
            service.addMessage(body).then((var message) {
                _toast.show();
            });
        }
    }
    
    void onDialogOpen(var e) {
        if (e.detail) {
            _text.value = "";
            _textContainer.update();
            _decorator.updateLabelVisibility("");
        }
    }
    
    void onInputChanged(var e) {
        _decorator.isInvalid = false;
    }
}