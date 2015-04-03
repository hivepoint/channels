part of chnls_core;

abstract class Service {
  LifeCycle _lifecycle;
  
  Service() {
    new LifeCycle().onShutdown().listen((_) {
      _onStop();
    }); 
  }
  
  void _onStop();
}

class LifeCycle {
  static final LifeCycle _singleton = new LifeCycle._internal();
  factory LifeCycle() => _singleton;
  Completer _lifecycle;
  Stream _lifecycleStream;

  LifeCycle._internal() {
    _lifecycle = new Completer();
    _lifecycleStream = new Stream.fromFuture(_lifecycle.future).asBroadcastStream();
  }

  
  Stream onShutdown() {
    return _lifecycleStream;
  }
  
  void shutdown() {
    _lifecycle.complete();  
  }
}
