import 'dart:collection';
import 'dart:js';

final JsObject _ProxyLib = context["ProxyLib"];
final JsObject _polymerInteropDartES6 = _ProxyLib['Basic'];
final JsObject _polymerDartES6 = _ProxyLib['Objects'];

JsObject createJsWrapper(Function factory) {
  return _ProxyLib['createDartTypeProxy'].apply([() => convertToJs(factory())]);
}


abstract class JsDartObject {
  JsObject get jsObject;
}


abstract class JsReflectiveDartObject implements JsDartObject {
  JsObject _jsObject;

  Set<String> get reflectedProperties;
  Set<String> get reflectedMethods;

  readProperty(String propertyName);

  writeProperty(String propertyName,value);

  invokeMethod(String methodName,List arguments);

  JsObject get jsObject {
    if (_jsObject == null) {
      _jsObject = _buildES6JsProxy(this);
    }
    return _jsObject;
  }

}


/// Wraps an instance of a dart class in a js proxy.


final JsFunction _createES6JsProxy = initES6Proxy();

JsObject _buildES6JsProxy(JsReflectiveDartObject instance) {
  return _createES6JsProxy.apply([instance]);
}

final JsFunction _createMethodInvoker = _polymerDartES6['createMethodInvoker'];

/// Hooks for ES6 Proxies
///
/// Hooks for getting and setting properties and methods from and to dart objects.
///
JsFunction initES6Proxy() {
  <String, Function>{
    '_dartGetter': (JsReflectiveDartObject dartInstance, propertyName) {

      Set<String> properties = dartInstance.reflectedProperties;

      if (properties.contains(propertyName)) {
        return convertToJs(dartInstance.readProperty(propertyName));
      }

      if (!dartInstance.reflectedMethods.contains(propertyName)) {
        return _Unsupported;
      }
      return _createMethodInvoker.apply([
          (List args) => convertToJs(dartInstance.invokeMethod(
              propertyName, args.map((x) => convertToDart(x)).toList()))
        ]);

    },
    '_dartGetProperties': (JsReflectiveDartObject dartInstance) {

      return new JsObject.jsify({
        "props": new JsArray.from(dartInstance.reflectedProperties),
        "mets": new JsArray.from(dartInstance.reflectedMethods)
      });
    },
    '_dartSetter': (JsReflectiveDartObject dartInstance, propertyName, value) {
      if (!dartInstance.reflectedProperties.contains(propertyName)) {
        return _Unsupported;
      }

      // TODO(dam0vm3nt): support for static

      dartInstance.writeProperty(propertyName, convertToDart(value));
    }
  }.forEach((String k, Function fun) {
    _polymerDartES6[k] = fun;
  });

  return _polymerDartES6['createES6JsProxy'];
}


convertToJs(something) {
  if (something is JsDartObject) {
    return something.jsObject;
  } else if (something is List) {
    return convertListToJs(something);
  } else if (something is Map) {
    return convertMapToJs(something);
  } else if (something is JsObject) {
    return something;
  } else {
    return something;
  }
}

convertToDart(var jsObject) {
  if (jsObject is! JsObject) {
    return jsObject;
  }
  var res = jsObject['__dartClass__'];
  if (res != null) {
    return res;
  }

  // Array are list
  if (jsObject is JsArray) {
    res = new JsArrayList.from(jsObject);
    _jsArrayCache[res] = jsObject;
    return res;
  }

  // Maps
  res = new JsObjectMap.from(jsObject);
  _jsMapCache[res] = jsObject;
  return res;
}


class JsArrayList extends ListBase implements JsDartObject {
  JsArray _jsArray;

  JsArrayList.from(JsArray jsArray) {
    this._jsArray = jsArray;
  }

  @override
  int get length => _jsArray.length;

  set length(l) => _jsArray.length = l;

  @override
  operator [](int index) => convertToDart(_jsArray[index]);

  @override
  void operator []=(int index, value) {
    _jsArray[index] = convertToJs(value);
  }

  @override
  JsObject get jsObject => _jsArray;
}

class JsObjectMap extends MapBase implements JsDartObject {
  JsObject _jsObject;

  JsObjectMap.from(JsObject jsObject) {
    this._jsObject = jsObject;
  }

  @override
  operator [](Object key) => convertToDart(_jsObject[key]);

  @override
  operator []=(key, value) {
    var res = this[key];
    _jsObject[key] = convertToJs(value);
    return res;
  }

  @override
  void clear() {
    List _keys = new List.from(keys);
    _keys.forEach((k) => remove(k));
  }

  @override
  JsObject get jsObject => _jsObject;


  @override
  Iterable get keys => _Object.callMethod("keys", [_jsObject]);

  @override
  remove(Object key) {
    var res = this[key];
    _jsObject.deleteProperty(key);
    return res;
  }
}

Expando<JsArray> _jsArrayCache = new Expando<JsArray>();
JsArray convertListToJs(List list) {
  JsArray res = _jsArrayCache[list];
  if (res == null) {
    res = createES6JsProxyForList(list);
    _jsArrayCache[list] = res;
  }
  return res;
}


Expando<JsArray> _jsMapCache = new Expando<JsArray>();
JsObject convertMapToJs(Map map) {
  JsObject res = _jsMapCache[map];
  if (map == null) {
    res = createES6JsProxyForMap(map);
    _jsMapCache[map] = res;
  }
  return res;
}

final JsFunction _createES6JsProxyForArrayJs = _initES6ListProxySupport();

final JsFunction _createES6JsProxyForMapJs = _initES6MapProxySupport();

JsObject createES6JsProxyForList(List list) =>
    _createES6JsProxyForArrayJs.apply([list]);

JsArray createES6JsProxyForMap(Map map) =>
    _createES6JsProxyForMapJs.apply([map]);

final JsObject _Unsupported = _polymerInteropDartES6['Unsupported'];

/// Hooks for ES6 Proxies
///
/// Hooks for getting and setting properties and methods from and to dart objects.
///
JsFunction _initES6ListProxySupport() {
  <String, Function>{
    '_dartArrayGet': (List instance, int index) => convertToJs(instance[index]),
    '_dartArrayPut': (List instance, int index, val) {
      if (index>=instance.length) {
        instance.length = index+1;
      }
      instance[index] = convertToDart(val);
      return true;
    },
    '_dartArrayLength': (List instance) => instance.length,
  }.forEach((String k, Function fun) {
    _polymerInteropDartES6[k] = fun;
  });

  return _polymerInteropDartES6['createES6JsProxyForArray'];
}

JsFunction _initES6MapProxySupport() {
  <String, Function>{
    '_dartGet': (Map instance, key) => convertToJs(instance[key]),
    '_dartPut': (Map instance, key, val) => instance[key] = convertToDart(val),
    '_dartKeys': (Map instance) =>
        new JsArray.from(instance.keys.map(convertToJs)),
  }.forEach((String k, Function fun) {
    _polymerInteropDartES6[k] = fun;
  });

  return _polymerInteropDartES6['createES6JsProxyForMaps'];
}



JsObject createJsProxy(Map<String, Function> handlers) {
  Map<String, JsFunction> jsHandlers = new Map<String, JsFunction>.fromIterable(handlers.keys, value: (String k) => new JsFunction.withThis(handlers[k]));

  return _ProxyLib.callMethod("createProxy", [new JsObject.jsify(jsHandlers)]);
}

JsObject createJsProxy2(JsObject target, Map<String, Function> handlers) {
  Map<String, JsFunction> jsHandlers = new Map<String, JsFunction>.fromIterable(handlers.keys, value: (String k) => new JsFunction.withThis(handlers[k]));

  return _ProxyLib.callMethod("createProxy2", [target, new JsObject.jsify(jsHandlers)]);
}

class DartPropProxy {
  Function dartGetter;
  Function dartSetter;

  DartPropProxy({this.dartGetter, this.dartSetter});
}

JsObject createDartTypeProxy(Function factoryFunc, Map<String, DartPropProxy> props, mets) {
  Map<String, JsObject> jsProps =
      new Map.fromIterable(props.keys, value: (k) => new JsObject.jsify({'dartGetter': allowInterop(props[k].dartGetter), 'dartSetter': allowInterop(props[k].dartSetter)}));

  return _ProxyLib.callMethod("createDartTypeProxy", [allowInterop(factoryFunc), new JsObject.jsify(jsProps), mets]);
}



final _Object = context['Object'];
final _ObjectPrototype = _Object['prototype'];
final _String = context['String'];
final _Number = context['Number'];
final _Boolean = context['Boolean'];
final _Array = context['Array'];
final _Date = context['Date'];
