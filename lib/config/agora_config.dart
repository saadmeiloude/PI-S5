class AgoraConfig {
  // Replace with your Agora App ID
  static const String appId = 'YOUR_AGORA_APP_ID';

  // Replace with your Agora Token (or use token server for production)
  static const String token = 'YOUR_AGORA_TOKEN';

  // Channel name prefix for video calls
  static String generateChannelName(String userId, String doctorId) {
    return 'call_${userId}_${doctorId}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
