# How the App Filters Devices (The "Secret Handshake")

This document explains exactly how the Sender ensures it **only** sees other devices running this specific app, ignoring random Bluetooth devices like headphones, speakers, or other phones.

## 1. The "Secret Key": Manufacturer ID `0x1234`

In Bluetooth Low Energy (BLE), every advertisement packet can contain **Manufacturer Specific Data**. This is a special field normally used by companies (like Apple, Samsung, Fitbit) to put their unique ID.

*   **We are using a custom ID:** `0x1234` (In a real production app, you would register a real ID with the Bluetooth SIG, but `0x1234` works perfectly for testing).
*   **This is our "Secret Handshake".**

## 2. The Receiver (Advertising)
When the Receiver starts advertising (via our Native Android code), it constructs a packet that looks like this:

| Field | Value | Note |
| :--- | :--- | :--- |
| **Manufacturer ID** | **`0x1234`** | **<-- The Key** |
| **Manufacturer Data** | `[0x48, 0x65, 0x6C, 0x6C, 0x6F]` | The bytes of your **Message** (e.g., "Hello") |
| Connectable | `false` | It's just broadcasting, like a Beacon |

**Crucially:** Standard Bluetooth devices (like your AirPods) **DO NOT** broadcast Manufacturer ID `0x1234`. They broadcast their own IDs (e.g., Apple is `0x004C`).

## 3. The Sender (Scanning & Filtering)
The Sender scans for *all* BLE devices nearby. This includes everything: your neighbor's TV, your smartwatch, and our Receiver app.

**However, we apply a strict filter in the code:**

```dart
// lib/sender_screen.dart

FlutterBluePlus.scanResults.listen((results) {
  // Filter: Keep ONLY devices that have our Secret Key (0x1234)
  _scanResults = results.where((r) {
    return r.advertisementData.manufacturerData.containsKey(0x1234);
  }).toList();
});
```

### The Logic Flow:
1.  **Scanner picks up a device.**
2.  **Check:** Does this device have Manufacturer Data with ID `0x1234`?
    *   **If YES:** It's our app! Add it to the list.
    *   **If NO:** It's a random device (Headphones, TV, etc.). **Ignore it.**

## 4. Why other devices are invisible
*   **Your Headphones:** Broadcast Manufacturer ID `0x004C` (Apple) or `0x0075` (Samsung). The filter `containsKey(0x1234)` returns `false`. **Ignored.**
*   **Random Phone:** Might broadcast nothing or a different ID. **Ignored.**
*   **Our Receiver:** Broadcasts `0x1234`. **Accepted.**

## Summary
The system works like a radio tuned to a specific frequency.
*   **Receiver:** Broadcasts ONLY on frequency `0x1234`.
*   **Sender:** Listens to everything, but ONLY plays sound from frequency `0x1234`.

This guarantees that the user **only** sees devices running your app.
