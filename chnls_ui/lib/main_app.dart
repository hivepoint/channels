import 'dart:html';
import 'package:polymer/polymer.dart';
import "core/core_ui.dart";

@CustomTag('main-app')
class MainApp extends PolymerElement {
    @observable String toolbarTitle = "All channels";
    
    DivElement _mainContainer;
    
    MainApp.created() : super.created();
    
    void attached() {
        _mainContainer = shadowRoot.querySelector("#centerContainer");
        router.defaultPlace = new Place(placeKey: "main");
        router.onPlaceChange.listen((Place place) {
            handlePlace(place);
        });
        router.refresh();
    }
    
    void handlePlace(Place place) {
        _mainContainer.children.clear();
        
        switch (place.key.toLowerCase()) {
            case 'main':
            default:
                _mainContainer.append(new Element.tag("feed-view"));
                break;
        }
    }
}
