import 'dart:io';

import 'package:example/src/provider/imageProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

void main() {
  Paint.enableDithering = true;
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PickerDataProvider())
      ],
      child: const MyApp(),
    )
  );
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
      home: Example(),
    );
  }
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  bool _singlePick = false;
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Consumer<PickerDataProvider>(
        builder: (context, media, _){
          return  Scaffold(
            body: Column(
              children: [
                Container(
                  height: 340,
                  color: Colors.black,
                  child: PageView(
                    children: [
                      ...media.pickedFile.map((data) {
                        if(data['type'] == 'image'){
                          return Center(
                            child: PhotoView.customChild(
                              child: Image.file(File(data['path'])),
                              enablePanAlways: true,
                              maxScale: 2.0,
                              minScale: 1.0,
                            ),
                          );
                        } else{
                          return Container(color: Colors.blue,);
                        }
                      })
                    ],
                  ),
                ),
                Expanded(
                  child: GalleryMediaPicker(
                    //viewType: ViewType.gridWithPreView,
                    childAspectRatio: 1,
                    crossAxisCount: 3,
                    singlePick: _singlePick,
                    maxPickImages: 5,
                    appBarHeight: 60,
                    selectedBackgroundColor: Colors.black,
                    pathList: (paths) {
                      setState(() {
                        /// for this example i use provider, you can choose the state management that you prefer
                        media.pickedFile = paths;
                      });
                    },
                    appBarLeadingWidget: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15,bottom: 12),
                        child: SizedBox(
                          height: 30,
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _singlePick = !_singlePick;
                                    });
                                    debugPrint(_singlePick.toString());
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 1.5
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Select multiple',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10
                                            ),
                                          ),
                                          const SizedBox(width: 7,),
                                           Transform.scale(
                                             scale: 1.5,
                                             child: Icon(
                                              _singlePick ? Icons.check_box_outline_blank : Icons.check_box_outlined,
                                              color: Colors.blue,
                                               size: 10,
                                          ),
                                           )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
