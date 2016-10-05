import 'package:polymer_element/polymer_element.dart';

@PolymerRegister('my-other-tag',template:'my_other_tag.html')
class MyOtherTag extends PolymerElement {
  void connectedCallback() {
    super.connectedCallback();
    print("OTHER CONNECTED");
  }
}
