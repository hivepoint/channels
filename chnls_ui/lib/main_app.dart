import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import "core/core_ui.dart";
import "components/splash_view.dart";

@CustomTag('main-app')
class MainApp extends PolymerElement {
    @observable String toolbarTitle = "All channels";
    
    DivElement _mainContainer;
    SplashView _splash;
    List subs = [];
    
    MainApp.created() : super.created();
    
    void attached() {
        super.attached();
        _mainContainer = shadowRoot.querySelector("#centerContainer");
        _splash = shadowRoot.querySelector("#splash");
        
//        router.defaultPlace = new Place(placeKey: "main");
//        router.onPlaceChange.listen((Place place) {
//            handlePlace(place);
//        });
//        router.refresh();
        
        _splash.onDismissSplash.listen((_) {
            _splash.style.opacity = "0";
            new Future.delayed(new Duration(milliseconds:300), () {
                _splash.style.display = "none";
            });
        });
    }
    
    void handlePlace(Place place) {
        _mainContainer.children.clear();
        
        switch (place.key.toLowerCase()) {
            case 'main':
            default:
                _mainContainer.append(new Element.tag("feed-view-old"));
                break;
        }
    }
}
