define(['polymer_dcc','dart_sdk','polymer_element_dart'],function(polymer_dcc,sdk,polymer_element_dart) {

  console.log("ENTER");



  class MyTag extends Polymer.Element {

    static get is() {
      return 'my-tag';
    }

    static get config() {
      return {};
    }

    constructor() {
      super();
    }


  }

  sdk.dart.registerExtension(MyTag,polymer_dcc.index.MyDartTag);

  console.log("IS 1: "+(polymer_element_dart instanceof Polymer.Element));

  console.log("IS 2: "+(polymer_dcc.index.MyDartTag instanceof Polymer.Element));

  console.log("IS 3: "+(polymer_dcc.index.MyDartTag instanceof polymer_element_dart));

  console.log("IS 4: "+(polymer_dcc.index.MyDartTag instanceof MyTag));


  // customElements.define( MyTag.is,polymer_dcc.index.MyDartTag);

  return {
    'js':MyTag,
    'dart' : polymer_dcc.index.MyDartTag
  };

});
