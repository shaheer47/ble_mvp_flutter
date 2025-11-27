import 'package:flutter/material.dart';
import 'package:ble_messenger/ble_messenger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _bleMessengerPlugin = BleMessenger();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _bleMessengerPlugin.startAdvertising("Test Message");
                },
                child: const Text("Start Advertising"),
              ),
              ElevatedButton(
                onPressed: () {
                  _bleMessengerPlugin.stopAdvertising();
                },
                child: const Text("Stop Advertising"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
