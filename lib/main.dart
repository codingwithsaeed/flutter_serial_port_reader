// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:serial/serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serial Port Reader',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const MyHomePage(title: 'Serial Port Reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SerialPort? _port;
  ReadableStreamReader? reader;

  Future<void> _openPort() async {
    final port = await window.navigator.serial.requestPort();
    await port.open(baudRate: 19200);
    _port = port;
    reader = _port!.readable.reader;
    setState(() {});
  }

  Stream<String> geneatedStream() async* {
    while (true) {
      if (_port == null || reader == null) {
        log('Not Connected');
        yield 'Not Connected';
      } else {
        final result = await reader!.read();
        final text = String.fromCharCodes(result.value);
        log('test: $text');
        yield text;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(),
            StreamBuilder(
              stream: geneatedStream(),
              builder: ((context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return const Center(child: Text('Not Connected'));
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                      ),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasData) {
                      return Center(
                        child: Text(snapshot.data ?? '',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 36,
                            )),
                      );
                    } else {
                      return const Center(child: Text('Empty data'));
                    }
                }
              }),
            ),
            const Spacer(),
            Visibility(
              visible: _port == null,
              child: ElevatedButton(
                  onPressed: () => _openPort(),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Open Serial Port'),
                  )),
            ),
            const SizedBox(height: 16),
            Visibility(
              visible: _port != null,
              child: ElevatedButton(
                  onPressed: () {
                    reader?.releaseLock();
                    _port?.close();
                    _port = null;
                    reader = null;
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Close Port'),
                  )),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
