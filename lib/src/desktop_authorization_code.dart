class DesktopAuthorizationCodeFlow {
  late String authorizationUrl;
  late String tokenUrl;
  late String clientId;
  late String redirectUri;
  late String authState;
  late List<String> scopes;
  late int localPort;
  String? clientSecret;
  bool pkce = true;
  //This html code will be sends as response to browser when the redirect uri hit the dart localserver with authorization code 
  String? htmlResponsePayload;
}