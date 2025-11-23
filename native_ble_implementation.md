# Native BLE Implementation for MVP

## Why Native Code?
We encountered a persistent `PlatformException(18)` (Advertise Data Too Large) on the Android Receiver, even when reducing the advertisement payload to a few bytes. This suggests that the Flutter plugin (`flutter_ble_peripheral`) might be:
1.  Adding implicit data (Flags, TxPower) that we cannot disable.
2.  Not correctly setting `legacyMode = true` for older devices or compatibility.
3.  Interacting poorly with the specific Bluetooth stack of the test device (Samsung A205F).

By moving to **Native Android (Kotlin)**, we gain:
*   **Direct Control**: We can call `BluetoothLeAdvertiser` directly.
*   **Exact Configuration**: We can explicitly set `setLegacyMode(true)`, `setConnectable(false)`, and build the `AdvertiseData` byte-by-byte.
*   **Better Debugging**: We can log the exact success/failure callbacks from the Android OS.

## Architecture
*   **Flutter**: `ReceiverScreen` uses a `MethodChannel` (`com.example.ble_mvp_v2/ble`) to send a command `startAdvertising` with the unique ID.
*   **Android (Kotlin)**: `MainActivity.kt` intercepts this call, configures the native `BluetoothLeAdvertiser`, and starts advertising. It returns the result back to Flutter.

## Implementation Details
*   **Service UUID**: We will use a 16-bit UUID `0xABCD` (or a full 128-bit one if space permits in native) to identify our app.
*   **Payload**: We will place the **User's Custom Message** (max 20 chars) in the **Manufacturer Data** field.
*   **Mode**: Non-Connectable (Broadcaster) to minimize overhead.

## Flow
1.  **Flutter**: `_startAdvertising()` -> `platform.invokeMethod('startAdvertising', {'id': 'Hello World'})`
2.  **Android**:
    *   Check Permissions.
    *   Get `BluetoothLeAdvertiser`.
    *   Create `AdvertiseSettings` (Mode: Low Latency, TxPower: Medium, Connectable: False).
    *   Create `AdvertiseData` (Include Device Name: False, Manufacturer Data: [Message Bytes]).
    *   Call `startAdvertising()`.
3.  **Android**: `onStartSuccess` -> Send "Success" to Flutter.
4.  **Flutter**: Update UI to "Advertising...".
