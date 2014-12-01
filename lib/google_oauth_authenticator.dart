import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import "package:google_oauth2_client/google_oauth2_browser.dart";

/// The `google-oauth-authenticator` element provides an authentication service
/// in Dart for Polymer apps that wish to use OAuth 2.0 for Google services or signin.
@CustomTag('google-oauth-authenticator')
class GoogleOAuthAuthenticator extends PolymerElement {
/// The `authenticated` event is fired when the authenticator has received
/// confirmation from the api and has tokens to be used and fired again
/// every token refresh.
///
/// @event authenticated

/// The [clientId] attribute stores the client id for the given project.
/// @attribute clientId
/// @type String
  @published String clientId;

/// The [scopes] attribute is a space delimited list of the request OAuth scopes.
/// @attribute scopes
/// @type List<String>
  @published List<String> scopes;

/// The [auto] attribute makes the authentication happen automatically when loaded.
/// @attribute auto
/// @type bool
  @published bool auto = true;

/// The [forcePrompt] attribute forces a credential prompt to be shown.
/// @attribute forcePrompt
/// @type bool
  @published bool forcePrompt = false;

/// The [forceLoadToken] attribute forces to load the cached token.
/// @attribute forceLoadToken
/// @type bool
  @published bool forceLoadToken = false;

  GoogleOAuth2 _auth;

  GoogleOAuthAuthenticator.created() : super.created() {
    if(auto){
      authorize(false, tokenLoaded, tokenNotLoaded);
    }
  }

/// The [authorize] method sends an authorization request to OAuth
///
/// @method authorize
/// @param {Boolean} prompt Defines wether or not the request should be made in immediate mode (i.e, prompt pop-up)
/// @param {Function} tokenLoadedCallback Defines a callback function to be executed that processes the valid token output.
/// @param {Function} tokenNotLoadedCallback Defines a callback function to be executed that processes when a token could not be produced.
  void authorize(bool prompt, tokenLoadedCallback, tokenNotLoadedCallback){
    if (_auth != null){
      _auth.login(immediate: !prompt, onlyLoadToken: forceLoadToken)
      .whenComplete(tokenLoadedCallback)
      .catchError(tokenNotLoadedCallback);
    } else {
      _auth = new GoogleOAuth2(
          clientId,
          scopes,
          tokenLoaded: tokenLoadedCallback,
          tokenNotLoaded: tokenNotLoadedCallback,
          autoLogin: !prompt && !forcePrompt,
          approval_prompt: forcePrompt?'force':'auto',
          autoLoadStoredToken: forceLoadToken);
    }
  }

/// The [tokenLoaded] method handles a token.
///
/// @method tokenLoaded
/// @param {Token} token Defines the return object from the oauth server.
  void tokenLoaded(Token token){
    dispatchEvent(new CustomEvent('authenticated', detail: token));
    Duration duration = token.expiry.difference(new DateTime.now());
    Timer timer = new Timer(duration, refresh);
  }

/// The [tokenNotLoaded] method handles the failure getting a token.
///
/// @method tokenNotLoaded
  tokenNotLoaded(){
    authorize(true, tokenLoaded, tokenNotLoaded);
  }

/// The [refresh] method handles the refresh of tokens.
///
/// @method refresh
  void refresh(){
    authorize(false, tokenLoaded, tokenNotLoaded);
  }

  _redo(){
    if(_auth!=null){
      _auth = null;
      authorize(false, tokenLoaded, tokenNotLoaded);
    }
  }

  autoChanged() {
    if(auto){
      authorize(false, tokenLoaded, tokenNotLoaded);
    }
  }

  clientIdChanged(){
    _redo();
  }

  scopesChanged(){
    _redo();
  }

  forcePromptChanged(){
    _redo();
  }

  forceLoadTokenChanged(){
    _redo();
  }
}