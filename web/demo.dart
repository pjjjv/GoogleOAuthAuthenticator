import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:template_binding/template_binding.dart';
import 'package:core_elements/core_ajax_dart.dart';
import "package:google_oauth2_client/google_oauth2_browser.dart";

void main() {
  initPolymer().run(() {

    Polymer.onReady.then((_) {
      var autoBind = document.querySelector('#auto-bind');
      templateBind(autoBind).model = new MyModel();
    });
  });
}

class MyModel extends Observable {
  @observable String greeting = "";

  void authenticated(CustomEvent event, Token token) {
    if (token.expired){
      throw new Exception("Token expired");
    }
    Map headers = {"Content-type": "application/json",
               "Authorization": "${token.type} ${token.data}"};
    CoreAjax ajax = querySelector('#ajax');
    ajax.headers = headers;
    ajax.go();
  }

  void ajaxError(CustomEvent event, Map detail, CoreAjax node) {
    print(detail);
  }

  void ajaxResponse(CustomEvent event, Map detail, CoreAjax node) {
    greeting = "Hello, ${detail['response']['name']}!";
  }
}
