import 'package:flutter/material.dart';

import './src/pages/index.dart';

void main() => runApp(VideoChat());

class VideoChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anon',
      debugShowCheckedModeBanner: false,
       color: Colors.white,
      home: IndexPage(),
    );
  }
}
