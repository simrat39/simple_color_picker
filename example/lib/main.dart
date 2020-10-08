import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_color_picker/simple_color_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: RaisedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: SimpleColorPicker(
                    height: MediaQuery.of(context).size.height * 0.55,
                    onColorSelect: (color) {
                      print(color);
                      Navigator.of(context).pop();
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    initialColor: Color(0xffe50050),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
