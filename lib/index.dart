import 'dart_proxy.dart';
import 'dart:js';
import 'dart:html';
import 'package:polymer_element/polymer_element.dart' as polymer;

class MyDartTag extends polymer.Element {

  String something = "hi";

  MyDartTag()  {
    print("Hi");
  }

  hello(Event ev,details) {
    print("hello");
  }


}



class MyDartClazza {

  String pippo;

  MyDartClazza() {
    print("Clazza Created");
  }

  hello(String me) {
    print("Hello ${me}");
  }

}

abstract class MyObjectTest extends JsDartObject {
  String name;
  int number = 0;

  int incrementBy(int val) {
    number += val;
    return number;
  }

  void helloMe(Event ev,details) {
    print("Hello here!");
  }

  void beforeRegister() {
    jsObject['is']='my-tag';
  }
}

class Property {
  Function read;
  Function write;

  Property({this.read,this.write});
}

class MyObjectReflectiveTest extends MyObjectTest with JsReflectiveDartObject {
  Map<String,Function> _methods= {
    'incrementBy' : (MyObjectTest self,List args) {
      return self.incrementBy(args[0]);
    },
    'helloMe' : (MyObjectTest self, List args) {
      return self.helloMe(args[0], args[1]);
    },
    'beforeRegister' : (MyObjectTest self,List args) {
      self.beforeRegister();
    }
  };

  Map<String,Property> _properties = {
    'name' : new Property(read : (MyObjectTest self) => self.name, write: (MyObjectTest self,value) => self.name = value),
    'number' : new Property(read: (MyObjectTest self) => self.number, write: (MyObjectTest self,value) => self.number = value)
  };


  @override
  invokeMethod(String methodName, List arguments) {
    return _methods[methodName](this,arguments);
  }

  @override
  readProperty(String propertyName) {
    return _properties[propertyName].read(this);
  }

  // TODO: implement reflectedMethods
  @override
  Set<String> get reflectedMethods => new Set.from(_methods.keys);

  // TODO: implement reflectedProperties
  @override
  Set<String> get reflectedProperties => new Set.from(_properties.keys);

  @override
  writeProperty(String propertyName, value) {
    _properties[propertyName].write(this,value);
  }
}

JsObject MyTag() =>  createJsWrapper(() => new MyObjectReflectiveTest());

void polymerMyTag(JsFunction polymer) {
  //polymer.apply([MyTag()]);

  JsObject Y= createJsWrapper(() => new MyObjectReflectiveTest());
  context['Polymer'].apply([Y]);
}

void main() {

  MyObjectTest obj = new MyObjectReflectiveTest();
  JsObject y = convertToJs(obj);
  context.callMethod("doSomething",[y]);
  print("name : ${obj.name}");
  print("num : ${obj.number}");

  JsObject Y= createJsWrapper(() => new MyObjectReflectiveTest());
  MyObjectTest t = convertToDart(context.callMethod('doSomething2',[Y]));
  print("name : ${t.name}");
  print("numb : ${t.number}");

  //context['Polymer'].apply([Y]);
}
