import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Example(),
    );
  }
}
class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical,
        children: [
          Container(),
           GalleryMediaPicker(
             childAspectRatio: 1,
             crossAxisCount: 3,
             singlePick: false,
             maxPickImages: 3,
             pathList: (paths) {
               debugPrint(paths.toString());
             },
          )
        ],
      ),
    );
  }
}
