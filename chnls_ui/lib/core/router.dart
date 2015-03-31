part of core_ui;

final Router router = new Router();

class Router {
    final StreamController<Place> _controller = new StreamController<Place>();
    Place currentPlace;
    Place defaultPlace;
    
    Stream<Place> get onPlaceChange => _controller.stream;
    
    Router() {
        window.onHashChange.listen((HashChangeEvent e) {
            refresh();
        });
    }
    
    void refresh() {
        Place newPlace = new Place.fromToken(window.location.hash);
        if (newPlace.key.isEmpty) {
            if (defaultPlace == null) {
                return;
            }
            newPlace = defaultPlace;
        }
        
        if (currentPlace == null) {
            currentPlace = newPlace;
            _controller.add(currentPlace);
        } else {
            if (currentPlace == newPlace) {
                currentPlace = newPlace;
                return;
            } else {
                currentPlace = newPlace;
                _controller.add(currentPlace);
            }
        }
    }
    
    void goto(Place place) {
        if (place == null) {
            return;
        }
        String token = '#${place.key}';
        if (place.propertyNames.isNotEmpty) {
            bool first = true;
            for (String name in place.propertyNames) {
                if (first) {
                    token = '${token}:${name}=';
                    first = false;
                } else {
                    token = '${token}&${name}=';
                }
                String value = Uri.encodeComponent(place.getProperty(name));
                token = '${token}${value}';
            }
        }
        window.location.hash = token;
    }
}
