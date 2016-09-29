define(['dart_sdk','polymer_element'],function(dart_sdk,polymer_element){

  dart_sdk.dart.registerExtension(Polymer.Element,polymer_element.polymer_element.Element);

  return polymer_element.polymer_element.Element;

});
