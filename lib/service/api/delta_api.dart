import 'package:dio/dio.dart';

import '../../model/delta/db_delta.dart';

class ClientDbStateVO {
  int? clientId;
  int? clientTime;

  ClientDbStateVO({
    this.clientId,
    this.clientTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'clientTime': clientTime,
    };
  }

  ClientDbStateVO.fromJson(Map<String, dynamic> json) {
    clientId = json['clientId'];
    clientTime = json['clientTime'];
  }
}

class DbQueryVO {
  bool? queryAll;
  List<ClientDbStateVO>? clientStates;
  List<String>? dataIdList;
  String? dataType;
  int? securityVersion;

  DbQueryVO({
    this.queryAll = false,
    this.clientStates = const <ClientDbStateVO>[],
    this.dataIdList = const <String>[],
    this.dataType = '',
    this.securityVersion = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'queryAll': queryAll,
      'clientStates': clientStates,
      'dataIdList': dataIdList,
      'dataType': dataType,
      'securityVersion': securityVersion,
    };
  }

  DbQueryVO.fromJson(Map<String, dynamic> json) {
    queryAll = json['queryAll'];
    clientStates =
        json['clientStates']?.map((e) => ClientDbStateVO.fromJson(e));
    dataIdList = json['dataIdList'];
    dataType = json['dataType'];
    securityVersion = json['securityVersion'];
  }
}

class DbUploadVO<T> {
  int? clientId;
  List<DbDelta>? items;
  int? securityVersion;

  DbUploadVO({
    this.clientId,
    this.items,
    this.securityVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'items': items?.map((e) => e.toMap()),
      'securityVersion': securityVersion,
    };
  }
}

class DeltaApi {
  String baseUrl;
  String? token;
  String? clientId;
  int? securityVersion;

  DeltaApi({
    required this.baseUrl,
    this.token,
    this.clientId,
    this.securityVersion,
  });

  Future<List<DbDelta>?> queryOldPwdVersionDbDelta(List<int> versions) async {
    var response = await Dio().post(
      "$baseUrl/db/queryOldPwdDbDeltaList",
      options: Options(
        headers: {
          "token": token,
          "clientId": clientId,
          "securityVersion": securityVersion,
        },
        responseType: ResponseType.json,
      ),
      data: {
        "oldSecurityVersionList": versions,
      },
    );
    if (response.statusCode == 200) {
      var data = response.data;
      var jsonArr = data["data"];
      var deltas = <DbDelta>[];
      for (var doc in jsonArr) {
        deltas.add(DbDelta.fromMap(doc));
      }
      return deltas;
    }
    return null;
  }

  Future<List<DbDelta>?> queryDbDeltaList(DbQueryVO query) async {
    var response = await Dio().post(
      "$baseUrl/db/queryDbDeltaList",
      options: Options(
        headers: {
          "token": token,
          "clientId": clientId,
          "securityVersion": securityVersion,
        },
        responseType: ResponseType.json,
      ),
      data: query.toJson(),
    );
    if (response.statusCode == 200) {
      var data = response.data;
      var jsonArr = data["data"];
      var deltas = <DbDelta>[];
      for (var doc in jsonArr) {
        deltas.add(DbDelta.fromMap(doc));
      }
      return deltas;
    }
    return null;
  }

  Future<bool> uploadDbDelta(DbUploadVO params) async {
    var response = await Dio().post(
      "$baseUrl/db/uploadDbDelta",
      options: Options(
        headers: {
          "token": token,
          "clientId": clientId,
          "securityVersion": securityVersion,
        },
        responseType: ResponseType.json,
      ),
      data: params.toJson(),
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
