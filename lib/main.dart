import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:gs1decoder/gs1decoder.dart';

const gs1 = "]C10198032685692596320200253211170124100170242117008382";
void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      scanResult = ScanResult(barcodeScanRes);
    });
  }

  var scanResult = ScanResult(gs1);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: const Text('Barcode scan')),
      body: Container(alignment: Alignment.center, child: scanResult),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.camera_alt,
          color: Colors.blue,
        ),
        onPressed: () => scanBarcodeNormal(),
      ),
      bottomNavigationBar: const BottomAppBar(
          elevation: 20,
          color: Colors.blueAccent,
          notchMargin: 20,
          child: SizedBox(
            height: 50,
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    ));
  }
}

class ScanResult extends StatelessWidget {
  final String? scan;
  const ScanResult(
    this.scan, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return scan != null ? buildResult(scan!) : const Text("No Scan");
  }

  Widget buildResult(String gs1) {
    var decoder = GS1Decoder(GS1Config.create(fnc1: "]C1", gs: ""));
    var result = decoder.decodeGS1Barcode(gs1);
    var data = result.data.map(
        (e) => Text("${e.ai.description} \n ID: ${e.ai.id} Value: ${e.value}"));
    var errors = result.error.map((e) =>
        Text("${e.error.name} \n ${"${e.ai?.id ?? "Rest"}:"}${e.restGs1}"));

    final color = result.successful ? Colors.green : Colors.red;
    return Wrap(
      direction: Axis.vertical,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 5,
      children: [
        Text(
          gs1,
          style: TextStyle(backgroundColor: color),
        ),
        const Text(
          "Data:",
          style: TextStyle(fontSize: 20),
        ),
        ...data,
        const Text(
          "Errors",
          style: TextStyle(fontSize: 20),
        ),
        ...errors,
      ],
    );
  }
}
