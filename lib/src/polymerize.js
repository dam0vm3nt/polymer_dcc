define([], function() {
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



  function polymerize(type, tag, config) {
    let m = importDart(Polymer.Element, type);

    // Adding is and config
    Object.defineProperty(m, 'is', {
      get: function() {
        return tag || type.TAG;
      }
    });

    Object.defineProperty(m, 'config', {
      get: function() {
        return config || type.CONFIG;
      }
    });

    customElements.define(m.is, m);

    return m;

  }

  return polymerize;
});
