define(['dart_sdk'], function(sdk) {
  function importDart(jsClass, dartClass) {
    let res = class extends jsClass {
      constructor() {
        super();
        this['new'].apply(this);
      }
    };
    for (let p of Object.getOwnPropertyNames(dartClass.prototype)) {
      if (p != 'constructor') {
        Object.defineProperty(res.prototype, p, Object.getOwnPropertyDescriptor(
          dartClass.prototype, p));
      }
    }
    return res;
  }

  function typeOf(sig) {
    if (sig == sdk.core.int) {
      return Number;
    }

    if (sig == sdk.core.String) {
      return String;
    }

    return undefined;
  }

  function polymerize(type, tag, config) {
    let m = importDart(Polymer.Element, type);

    let sig = sdk.dart.getFieldSig(type);

    config = config || type.CONFIG || {};
    config.properties = config.properties || {};

    // Adding descriptors for props if not already there
    for (let pn in sig) {
      if (!(pn in config.properties)) {
        config.properties[pn] = {
          type: typeOf(sig[pn])
        }
      }
    }

    // Adding is and config
    Object.defineProperty(m, 'is', {
      get: function() {
        return tag || type.TAG;
      }
    });

    Object.defineProperty(m, 'config', {
      get: function() {
        return config;
      }
    });

    customElements.define(m.is, m);

    return m;

  }

  return polymerize;
});
