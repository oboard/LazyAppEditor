// import 'package:example/readme/readme_examples.dart';
import 'package:flutter/material.dart';

import 'custom_code_box.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Code field',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preset = <String>[
      "htmlbars|vs",
    ];
    List<Widget> children = preset.map((e) {
      final parts = e.split('|');
      print(parts);
      final box = CustomCodeBox(
        language: parts[0],
        theme: parts[1],
      );
      return Padding(
        padding: EdgeInsets.only(bottom: 32.0),
        child: box,
      );
    }).toList();
    final page = Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 900),
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Column(children: children),
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(),
    //   body: CodeEditor(),
    // );

    return Scaffold(
      backgroundColor: Color(0xFF363636),
      appBar: AppBar(
        backgroundColor: Color(0xff23241f),
        title: Text("LazyApp 编辑器"),
        // title: Text("Recursive Fibonacci"),
        centerTitle: false,
      ),
      body: SingleChildScrollView(child: page),
      // body: CodeEditor5(),
    );
  }
}
