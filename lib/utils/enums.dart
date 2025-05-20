enum ScanStatus {
  /// Default state before anything has started
  initial,

  /// Currently scanning or attempting connection
  loading,

  /// Successfully scanned and connected
  success,

  /// Device is currently connected
  connected,

  /// Device got disconnected after being connected
  disconnected,

  /// Tried to connect but failed (e.g., timeout or rejection)
  failed,

  /// General Bluetooth error (e.g., permissions, turned off, etc.)
  error,

  bluetoothPermissions,
}
