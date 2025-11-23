import 'package:flutter/material.dart';
import 'package:ble_messenger/ble_messenger.dart';

class SenderScreen extends StatefulWidget {
  const SenderScreen({super.key});

  @override
  State<SenderScreen> createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  final BleMessenger _messenger = BleMessenger();
  List<BleMessage> _scanResults = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    setState(() => _isScanning = true);
    
    // Listen to results from our package
    _messenger.scanForMessengers().listen((results) {
      if (mounted) {
        setState(() {
          _scanResults = results;
        });
      }
    });

    // Auto stop UI update (Scanning stops internally after 15s in package)
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }
  
  Future<void> _connectToDevice(BleMessage message) async {
    // Since Receiver is non-connectable, we simulate connection
    // We already have the message.
    
    _messenger.stopScanning();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text("Connecting...", style: TextStyle(color: Colors.white, decoration: TextDecoration.none))
        ],
      )),
    );
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context); // Pop loader
      
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("Connected!"),
          content: Text("Received Message: ${message.message}"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sender'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), 
            onPressed: _isScanning ? null : _startScanning
          )
        ],
      ),
      body: _scanResults.isEmpty
          ? Center(child: Text(_isScanning ? "Scanning..." : "No devices found."))
          : ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final msg = _scanResults[index];
                
                return ListTile(
                  title: const Text("Receiver Found"),
                  subtitle: Text("Message: ${msg.message}"),
                  leading: const Icon(Icons.bluetooth),
                  trailing: ElevatedButton(
                    onPressed: () => _connectToDevice(msg),
                    child: const Text("Connect"),
                  ),
                );
              },
            ),
    );
  }
}
