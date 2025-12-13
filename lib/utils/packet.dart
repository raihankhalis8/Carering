class PacketUtils {
  static List<int> makePacket(int command, [List<int>? subData]) {
    assert(command >= 0 && command <= 255, 'Invalid command');

    final packet = List<int>.filled(16, 0);
    packet[0] = command;

    if (subData != null) {
      assert(subData.length <= 14, 'Sub data must be less than 14 bytes');
      for (int i = 0; i < subData.length; i++) {
        packet[i + 1] = subData[i];
      }
    }

    packet[15] = _checksum(packet);
    return packet;
  }

  static int _checksum(List<int> packet) {
    return packet.reduce((a, b) => a + b) & 255;
  }

  static int byteToBcd(int b) {
    assert(b < 100 && b >= 0);
    final tens = b ~/ 10;
    final ones = b % 10;
    return (tens << 4) | ones;
  }

  static int bcdToDecimal(int b) {
    return (((b >> 4) & 15) * 10) + (b & 15);
  }
}
