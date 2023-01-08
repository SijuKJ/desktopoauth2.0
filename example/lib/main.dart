import 'package:example/oauth2_page.dart';
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
