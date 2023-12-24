import 'dart:typed_data';

int readLong(List<int> readBuffer, int offset) {
  return (readBuffer[0 + offset] << 56) +
      (readBuffer[1 + offset] << 48) +
      (readBuffer[2 + offset] << 40) +
      (readBuffer[3 + offset] << 32) +
      (readBuffer[4 + offset] << 24) +
      (readBuffer[5 + offset] << 16) +
      (readBuffer[6 + offset] << 8) +
      (readBuffer[7 + offset] << 0);
}

int readInt(List<int> readBuffer, int offset) {
  return (readBuffer[0 + offset] << 24) +
      (readBuffer[1 + offset] << 16) +
      (readBuffer[2 + offset] << 8) +
      (readBuffer[3 + offset] << 0);
}

List<int> writeInt(int v) {
  List<int> writeBuffer = [];
  writeBuffer.add(v >>> 24);
  writeBuffer.add(v >>> 16);
  writeBuffer.add(v >>> 8);
  writeBuffer.add(v >>> 0);
  return writeBuffer;
}

List<int> writeLong(int v) {
  List<int> writeBuffer = [];
  writeBuffer.add(v >>> 56);
  writeBuffer.add(v >>> 48);
  writeBuffer.add(v >>> 40);
  writeBuffer.add(v >>> 32);
  writeBuffer.add(v >>> 24);
  writeBuffer.add(v >>> 16);
  writeBuffer.add(v >>> 8);
  writeBuffer.add(v >>> 0);
  return writeBuffer;
}
