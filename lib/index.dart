import 'dart_proxy.dart';
import 'dart:js';


class MyDartClazza {

  String pippo;

  MyDartClazza() {
    print("Clazza Created");
  }

  hello(String me) {
    print("Hello ${me}");
  }

}

class MyObjectTest {
  String name;
  int number = 0;

  int incrementBy(int val) {
    number += val;
    return number;
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
}
