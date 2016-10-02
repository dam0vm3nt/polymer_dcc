import 'dart:js';
import 'dart:html';
import 'package:polymer_element/polymer_element.dart' as polymer;

class MyData {
  String _f;
  String field1;
  String get field2 => _f;
  set field2(String v) {
    print("SETTING F2 : ${v}");
    _f = v;
  }

  MyData({String field1,String field2}) {
    this.field1 = field1;
    this.field2 = field2;
  }
}

abstract class MyDartTag extends polymer.Element {
  static const TAG='my-tag';

  static JsObject CONFIG = new JsObject.jsify({
    'observers' : [
      'countChanged(count)'
    ]
  });

  int count=0;

  MyData data1;

  void countChanged(int newVal) {
    print("COUNT CHANGED : ${newVal} - ${count}");
  }

  String something = "hi";

  List cippi = [
    new MyData(field1:'a1',field2:'b1'),
    new MyData(field1:'a2',field2:'b2'),
    new MyData(field1:'a3',field2:'b3'),
  ];


  MyDartTag()  {
    print("Hi");
    data1 = new MyData(field1: 'uno',field2: 'due');
  }

  factory MyDartTag.create() => new Element.tag(TAG);

  hello(Event ev,details) {
    ev.preventDefault();
    print("hello :${ev} , ${details}");
    print("My Parent : ${this.parentNode}");
    print("Bounding box ${this.getBoundingClientRect()}");

    // Magical getters and setters in action here !
    count = count + 1;
    cippi.add(new MyData(field1:'x',field2:'y'));
    // Equivalent to notify (less performant)
    cippi = cippi;
    print("Count is : ${count}");
  }

  addAnother(Event ev,details) {
    this.parentNode.append(new MyDartTag.create());
  }

}
