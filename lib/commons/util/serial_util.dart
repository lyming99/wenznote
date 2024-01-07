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

int readInt32(List<int> readBuffer, int offset) {
  return ((readBuffer[0 + offset] << 24) +
          (readBuffer[1 + offset] << 16) +
          (readBuffer[2 + offset] << 8) +
          (readBuffer[3 + offset] << 0))
      .toSigned(32);
}

List<int> writeInt32(int v) {
  v = v.toUnsigned(32);
  List<int> writeBuffer = [];
  writeBuffer.add((v >>> 24) & 0xff);
  writeBuffer.add((v >>> 16) & 0xff);
  writeBuffer.add((v >>> 8) & 0xff);
  writeBuffer.add((v >>> 0) & 0xff);
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
