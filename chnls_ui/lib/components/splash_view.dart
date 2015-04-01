library splash_view;

import "dart:html";
import "dart:async";
import 'package:polymer/polymer.dart';

@CustomTag('splash-view')
class SplashView extends PolymerElement {
    SplashView.created() : super.created();
    
    @observable String progressStyle = "";
    DivElement _signinPanel; 
    
    final StreamController _controller = new StreamController();
    Stream get onDismissSplash => _controller.stream;
    
    void attached() {
        _signinPanel = shadowRoot.querySelector("#signinPanal");
        refresh();
    }
    
    void refresh() {
        const d = const Duration(seconds: 3);
        new Timer(d, () {
            progressStyle = "notvisible";
            _signinPanel.style.display = "block";
            new Timer(const Duration(milliseconds: 10), () {
                _signinPanel.style.opacity = "1";
                _signinPanel.style.transform = "none";
            });
        });
    }
    
    void onGoogleSignIn(var e) {
        _controller.add(null);
    }
}