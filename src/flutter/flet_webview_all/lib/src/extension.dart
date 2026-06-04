import 'package:flet/flet.dart';
import 'package:flutter/widgets.dart';

import 'flet_webview_all.dart';

class Extension extends FletExtension {
  @override
  Widget? createWidget(Key? key, Control control) {
    switch (control.type) {
      case "FletWebviewAll":
        return FletWebviewAllControl(control: control);
      default:
        return null;
    }
  }
}
