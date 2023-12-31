class ServerVO {
  String? host;
  int? port;

  ServerVO({
    this.host,
    this.port,
  });

  Map<String, dynamic> toMap() {
    return {
      'host': this.host,
      'port': this.port,
    };
  }

  factory ServerVO.fromMap(Map<String, dynamic> map) {
    return ServerVO(
      host: map['host'] as String?,
      port: map['port'] as int?,
    );
  }

}
