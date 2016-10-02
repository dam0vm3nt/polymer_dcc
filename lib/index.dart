import 'dart_proxy.dart';
import 'dart:js';
import 'dart:html';
import 'package:polymer_element/polymer_element.dart' as polymer;

class Tag {
  final String name;
  const Tag(this.name);
}

@Tag("my-tag")
abstract class MyDartTag extends polymer.Element {

  int count=0;

  String something = "hi";

  MyDartTag()  {
    print("Hi");
  }

  hello(Event ev,details) {
    ev.preventDefault();
    print("hello :${ev} , ${details}");
    print("My Parent : ${this.parentNode}");
    print("Bounding box ${this.getBoundingClientRect()}");
    set('count',count+1);
    print("Count is : ${count}");
  }


}

void main() {

}
