import 'package:flutter/material.dart';
import 'package:ble_messenger/ble_messenger.dart';

class ReceiverScreen extends StatefulWidget {
  const ReceiverScreen({super.key});

  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  final TextEditingController _messageController = TextEditingController();
  final BleMessenger _messenger = BleMessenger();
  bool _isAdvertising = false;

  @override
  void initState() {
    super.initState();
    _messageController.text = "Hello BLE!"; 
  }

  Future<void> _startAdvertising() async {
    String message = _messageController.text;
    
    try {
      if (_isAdvertising) {
        await _messenger.stopAdvertising();
      }
      
      await _messenger.startAdvertising(message);
      
      if (mounted) {
        setState(() {
          _isAdvertising = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Broadcasting: $message"))
        );
      }
    } catch (e) {
      debugPrint("Advertising failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _stopAdvertising() async {
    try {
      await _messenger.stopAdvertising();
      if (mounted) {
        setState(() {
          _isAdvertising = false;
        });
      }
    } catch (e) {
      debugPrint("Stop failed: $e");
    }
  }

  @override
  void dispose() {
    _messenger.stopAdvertising();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receiver')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter Message to Share:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLength: 20,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Type a short message",
                counterText: "Max 20 chars (BLE Limit)",
              ),
            ),
            const SizedBox(height: 20),
            if (_isAdvertising)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('Broadcasting: "${_messageController.text}"', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _stopAdvertising,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text("Stop Broadcasting"),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _startAdvertising,
                child: const Text("Start Broadcasting"),
              ),
            const SizedBox(height: 10),
            const Text('Mode: Broadcast (Non-Connectable)', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
