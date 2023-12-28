import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktopoauth2/src/desktop_authorization_code.dart';
import 'package:desktopoauth2/src/desktop_const.dart';
import 'package:http/http.dart' as http;
import 'package:pkce/pkce.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_to_front/window_to_front.dart';

class DesktopOAuth2 {
  HttpServer? _codeListenerServer;

  Future<void> _authorize(Uri authorizationUrl) async {
    if (await canLaunchUrl(authorizationUrl)) {
      await launchUrl(authorizationUrl);
    } else {
      throw Exception('Could not launch $authorizationUrl');
    }
  }

  Future<Map<String, String>?> _listenAuthorizationCode(DesktopAuthorizationCodeFlow desktopAuthCodeFlow) async {
    var request = await _codeListenerServer!.first;
    var params = request.uri.queryParameters;
    if (!request.uri.toString().startsWith(desktopAuthCodeFlow.redirectUri) && !params.containsKey("code")) {
      return null;
    }

    request.response.statusCode = 200;
    request.response.headers.set('content-type', 'text/html');

    if (desktopAuthCodeFlow.htmlResponsePayload != null) {
      request.response.writeln(desktopAuthCodeFlow.htmlResponsePayload);
    } else {
      request.response.writeln(htmlResponsePayload);
    }
    await request.response.close();
    await _codeListenerServer!.close();
    await WindowToFront.activate();
    _codeListenerServer = null;
    return params;
  }

  Future<Map<String, dynamic>?> _login(DesktopAuthorizationCodeFlow desktopAuthCodeFlow, Uri authorizationUrl, {String? codeVerifier}) async {
    await _codeListenerServer?.close();
    _codeListenerServer = await HttpServer.bind('localhost', desktopAuthCodeFlow.localPort);

    await _authorize(authorizationUrl);
    Map<String, String>? responseQueryParameters = await _listenAuthorizationCode(desktopAuthCodeFlow);

    if (responseQueryParameters != null && responseQueryParameters.containsKey("code")) {
      return _fetchAccessToken(desktopAuthCodeFlow, responseQueryParameters["code"]!, codeVerifier: codeVerifier);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchAccessToken(DesktopAuthorizationCodeFlow desktopAuthCodeFlow, String code, {String? codeVerifier}) async {
    Map<String, String> tokenReqPayload = {
      'client_id': desktopAuthCodeFlow.clientId,
      'client_secret': desktopAuthCodeFlow.clientSecret!,
      'redirect_uri': desktopAuthCodeFlow.redirectUri,
      'grant_type': 'authorization_code',
      'code': code
    };

    if (codeVerifier != null) tokenReqPayload.putIfAbsent("code_verifier", () => codeVerifier);

    final response = await http.post(Uri.parse(desktopAuthCodeFlow.tokenUrl), body: tokenReqPayload);

    return Map<String, dynamic>.from(json.decode(response.body));
  }

  Future<Map<String, dynamic>?> oauthorizeCode(DesktopAuthorizationCodeFlow desktopAuthCodeFlow) async {
    final params = StringBuffer();
    params.write("response_type=code");
    params.write("&scope=${desktopAuthCodeFlow.scopes.join(',')}");
    params.write("&client_id=${desktopAuthCodeFlow.clientId}");
    params.write("&redirect_uri=${desktopAuthCodeFlow.redirectUri}");
    params.write("&state=${desktopAuthCodeFlow.authState}");

    if (desktopAuthCodeFlow.pkce == true) {
      final pkcePair = PkcePair.generate();

      params.write("&code_challenge=${pkcePair.codeChallenge}");
      params.write("&code_challenge_method=S256");
      final Uri authUrl = Uri.parse('${desktopAuthCodeFlow.authorizationUrl}?${params.toString()}');

      return _login(desktopAuthCodeFlow, authUrl, codeVerifier: pkcePair.codeVerifier);
    } else {
      final Uri authUrl = Uri.parse('${desktopAuthCodeFlow.authorizationUrl}?${params.toString()}');

      return _login(desktopAuthCodeFlow, authUrl);
    }
  }
}
