import 'package:desktopoauth2/desktopoauth2.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DeskOAuth2ExampleApp());
}

class DeskOAuth2ExampleApp extends StatelessWidget {
  const DeskOAuth2ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter OAuth2 Desktop Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OauthPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class OauthPage extends StatefulWidget {
  const OauthPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OauthState createState() => _OauthState();
}

class _OauthState extends State<OauthPage> {
  String? accessToken;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Column(children: [
            Container(
                color: Colors.grey.shade100,
                height: 50,
                width: 130,
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.resolveWith<double?>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) return 16;
                      return null;
                    }),
                  ),
                  onPressed: () async {
                    DesktopOAuth2 desktopOAuth2 = DesktopOAuth2();

                    DesktopAuthorizationCodeFlow desktopAuthCodeFlow = DesktopAuthorizationCodeFlow();

                    desktopAuthCodeFlow.authState = 'xcoivjuywkdkhvusuye3kch';
                    desktopAuthCodeFlow.authorizationUrl = 'https://dev-7932731.okta.com/oauth2/aus12p5r7eLEams5g5d7/v1/authorize';
                    desktopAuthCodeFlow.clientId = '0oa7v0y4zkpnSMR175d7';
                    desktopAuthCodeFlow.localPort = 9298;
                    desktopAuthCodeFlow.pkce = true;
                    desktopAuthCodeFlow.redirectUri = 'http://localhost:9298/code';
                    desktopAuthCodeFlow.scopes = ['openid'];
                    desktopAuthCodeFlow.tokenUrl = 'https://dev-7932731.okta.com/oauth2/aus12p5r7eLEams5g5d7/v1/token';

                    desktopOAuth2.oauthorizeCode(desktopAuthCodeFlow).then((token) {
                      if (token != null && token.isNotEmpty) {
                        setState(() {
                          accessToken = token["access_token"];
                        });
                      }
                    });

                  
                  },
                  child: const Text('Authenticate'),
                )),
            Text(
              accessToken ?? '',
              style: const TextStyle(fontSize: 15, fontFamily: "poppins"),
            )
          ]),
        ));
  }
}
