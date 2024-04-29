import 'dart:typed_data';

import 'package:dio/dio.dart';

class UpdateDocStateInfo {
  String dataId;
  int updateTime;

  UpdateDocStateInfo({
    required this.dataId,
    required this.updateTime,
  });

  UpdateDocStateInfo.fromJson(Map<String, dynamic> json)
      : dataId = json['dataId'],
        updateTime = json['updateTime'];

  Map<String, dynamic> toJson() => {
        'dataId': dataId,
        'updateTime': updateTime,
      };
}

class LockResult{
    String? dataId;
    String? docState;
    int? securityVersion;
    int? updateTime;
}

class DocApi {
  String baseUrl;
  String? token;
  String? clientId;
  int? securityVersion;

  DocApi({
    required this.baseUrl,
    this.token,
    this.clientId,
    this.securityVersion,
  });

  Future<Response> downloadDoc(String docId, [String? docState]) async {
    return await Dio().post(
      "$baseUrl/doc/downloadDoc/$docId",
      options: Options(
        headers: {
          "token": token,
          "clientId": clientId,
          "securityVersion": securityVersion,
        },
        responseType: ResponseType.bytes,
      ),
      data: FormData.fromMap({
        "docState": docState,
      }),
    );
  }

  // query doc update list
  Future<List<UpdateDocStateInfo>?> queryUpdateList(int startTime) async {
    var response = await Dio().post(
      "$baseUrl/doc/queryUpdateDocList",
      options: Options(
        headers: {
          "token": token,
          "clientId": clientId,
          "securityVersion": securityVersion,
        },
        responseType: ResponseType.json,
      ),
      data: FormData.fromMap({
        "startTime": startTime,
      }),
    );
    if (response.statusCode == 200) {
      var data = response.data;
      var docList = data["data"];
      var docIdList = <UpdateDocStateInfo>[];
      for (var doc in docList) {
        docIdList.add(UpdateDocStateInfo.fromJson(doc));
      }
      return docIdList;
    }
    return null;
  }

  Future<LockResult?> queryDocStateAndLock(String docId) async {
    var response = await Dio().post(
      "$baseUrl/doc/queryDocStateAndLock/$docId",
      options: Options(
        headers: {
          "token": token,
          "clientId": clientId,
          "securityVersion": securityVersion,
        },
        responseType: ResponseType.json,
      ),
    );
    if (response.statusCode == 200) {
      var data = response.data;
      var docState = data["data"];
      return LockResult()
        ..dataId = docId
        ..docState = docState?['docState']
        ..securityVersion = docState?['securityVersion']
        ..updateTime = docState?['updateTime'];
    }
    return null;
  }

  Future<Response> uploadDoc(
      String docId, String docState, Uint8List docContent) async {
    return await Dio().post(
      "$baseUrl/doc/uploadDoc/$docId",
      options: Options(
        headers: {
          "token": token,
          "clientId": clientId,
          "securityVersion": securityVersion,
          "Content-Type": "multipart/form-data;"
        },
        responseType: ResponseType.bytes,
      ),
      data: FormData.fromMap({
        "docState": docState,
        "file": MultipartFile.fromBytes(docContent, filename: "doc.wnote"),
      }),
    );
  }
}
