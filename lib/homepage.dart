import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'dart:io';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List ss = Uint8List(0);
  TextEditingController _inputController;
  TextEditingController _outputController;

  @override
  initState() {
    super.initState();
    this._inputController = new TextEditingController();
    this._outputController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text("QR SCAN-GEN"),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          children: <Widget>[
            Container(
              color: Color.fromRGBO(255, 250, 250, 1),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  _qrWidget(this.ss, context),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: this._inputController,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (value) async {
                        Uint8List result = await scanner.generateBarCode(value);
                        this.setState(() => this.ss = result);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                          gapPadding: 5.0,
                        ),
                        helperText: 'Data for the generation of QRCode',
                        helperStyle: TextStyle(color: Colors.black),
                        labelText: 'Please Input Your Data for QR Code',
                        labelStyle: TextStyle(
                          fontSize: 15,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: this._outputController,
                      readOnly: true,
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                          gapPadding: 5.0,
                        ),
                        helperText: 'The Scanned Result',
                        helperStyle: TextStyle(color: Colors.black),
                        labelText: 'The results after scanning are :',
                        labelStyle: TextStyle(fontSize: 16),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buttongroup(_inputController, _outputController, ss),
                  SizedBox(height: 90)
                ],
              ),
            ),
          ],
        );
      }),
    ));
  }
}

Widget _qrWidget(Uint8List ss, BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(20),
    child: Card(
      elevation: 6,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Icon(Icons.verified_user, size: 18, color: Colors.green),
                Text(' Generated QR Code', style: TextStyle(fontSize: 18)),
                Spacer(),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 190,
                  child: ss.isEmpty
                      ? Center(
                          child: Text('The Generated QR Code displays here',
                              style: TextStyle(color: Colors.black38)),
                        )
                      : Image.memory(ss),
                ),
                Divider(height: 1, color: Colors.black26,),
                Padding(
                  padding: EdgeInsets.only(top: 7, left: 25, right: 25),
                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[

                         InkWell(
                            child: Container(
                              margin: EdgeInsets.only(right: 25),
                              child: Text(
                                'remove',
                                style:
                                    TextStyle(fontSize: 15, color: Colors.blue),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            onTap: () {
                              ss = Uint8List(0);
                            }),
                       SizedBox(width: 20,),

                       InkWell(
                          onTap: () async {
                            final success =
                                await ImageGallerySaver.saveImage(ss);
                            SnackBar snackBar;
                            if (success) {
                              snackBar = new SnackBar(
                                  content:
                                      new Text('Successful Preservation!'));
                              Scaffold.of(context).showSnackBar(snackBar);
                            } else {
                              snackBar = new SnackBar(
                                  content: new Text('Save failed!'));
                            }
                          },
                          child: Text(
                            'save',
                            style: TextStyle(fontSize: 15, color: Colors.blue),
                            textAlign: TextAlign.center,
                          ),
                        ),

                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(height: 1, color: Colors.black26),
        ],
      ),
    ),
  );
}

Widget _buttongroup(TextEditingController _inputController,
    TextEditingController _outputController, Uint8List ss) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      FloatingActionButton.extended(
        onPressed: () async {
          String barcode = await scanner.scan();
          _outputController.text = barcode;
        },
        label: Text(
          "Camera",
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
          Icons.camera,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[300],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
      ),
      FloatingActionButton.extended(
        onPressed: () async {
          String barcode = await scanner.scanPhoto();
          _outputController.text = barcode;
        },
        label: Text(
          "Gallery",
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
          Icons.photo_album,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[300],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
      ),
    ],
  );
}
