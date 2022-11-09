import 'package:flutter/material.dart';
import 'package:gs1decoder/gs1decoder.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

const gs1 = "]C10198032685692596320200253211170124100170242117008382";
void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var scanResult = const ScanResult(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode scan')),
      body: Container(alignment: Alignment.center, child: scanResult),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.camera_alt,
          color: Colors.blue,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Test((barcode) =>
                  setState(() => scanResult = ScanResult(barcode))),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomAppBar(
          elevation: 20,
          color: Colors.blueAccent,
          notchMargin: 20,
          child: SizedBox(
            height: 50,
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class ScanResult extends StatelessWidget {
  final Barcode? scan;
  const ScanResult(
    this.scan, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return scan != null ? buildResult(scan!) : const Text("No Scan");
  }

  Widget buildResult(Barcode bc) {
    return Wrap(
      direction: Axis.vertical,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 5,
      children: [
        Text(
          "Format: ${bc.format.name.toUpperCase()}",
          style: const TextStyle(fontSize: 15),
        ),
        Text(bc.rawValue ?? "Empty"),
        ...getBarcodeParsingResult(bc),
      ],
    );
  }
}

List<Widget> getBarcodeParsingResult(Barcode bc) {
  switch (bc.format) {
    case BarcodeFormat.code128:
      return parseCode128(bc.rawValue!);
    default:
      return [const SizedBox.shrink()];
  }
}

List<Widget> parseCode128(String gs1) {
  if (gs1.startsWith("]C1")) {
    var decoder = GS1Decoder(GS1Config.create(fnc1: "]C1", gs: ""));
    var result = decoder.decodeGS1Barcode(gs1);
    var data = result.data.map(
        (e) => Text("${e.ai.description} \n ID: ${e.ai.id} Value: ${e.value}"));
    var errors = result.error.map((e) =>
        Text("${e.error.name} \n ${"${e.ai?.id ?? "Rest"}:"}${e.restGs1}"));

    return [
      const Text(
        "Typ: GS1",
        style: TextStyle(fontSize: 20),
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
    ];
  } else {
    return [const SizedBox.shrink()];
  }
}

class Test extends StatelessWidget {
  final Function callback;
  const Test(this.callback, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner')),
      body: MobileScanner(
        controller: MobileScannerController(
          facing: CameraFacing.back,
          torchEnabled: false,
          // returnImage: true,
        ),
        onDetect: (barcode, args) {
          if (barcode.rawValue == null) {
            debugPrint('Failed to scan Barcode');
          } else {
            Future.delayed(Duration.zero, () {
              Navigator.popUntil(context, (route) => route.isFirst);
              ;
            });
            callback(barcode);
          }
        },
      ),
    );
  }
}
