import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:flutter_crdt/utils/doc.dart';
import 'package:get/get.dart';
import 'package:note/commons/service/file_manager.dart';
import 'package:note/config/app_constants.dart';
import 'package:note/model/client/client_vo.dart';
import 'package:note/model/user/user_vo.dart';
import 'package:note/service/config/config_manager.dart';
import 'package:note/service/isar/isar_service.dart';
import 'package:note/service/service_manager.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 登录
/// 登出
///   登出后关闭所有窗口，列表也刷新
///   切换数据库为本地数据库
/// 注册
/// 读取信息
class UserService with ChangeNotifier {
  ServiceManager serviceManager;
  UserVO? currentUser;
  String? token;
  ClientVO? client;

  UserService(this.serviceManager);

  bool get hasLogin => currentUser != null;

  String get userPath {
    return currentUser == null ? "" : "user-${currentUser!.id}/";
  }

  Dio get dio {
    var options = BaseOptions(headers: {"token": token});
    var dio = Dio(options);
    return dio;
  }

  int? get uid => currentUser?.id;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    //1.调用接口登录
    //2.将token保存到本地
    //3.将用户信息保存到本地
    //4.如果是首次登录，则提示用户是否将本地离线数据导入
    var result = await Dio().post(
      "${AppConstants.apiUrl}/user/login",
      data: {"email": email, "password": password, "loginType": 1},
      options: Options(contentType: "application/json"),
    );
    var data = result.data;
    if (data["msg"] == AppConstants.success) {
      //登录成功，data就是token信息
      token = data["data"];
      await fetchUserInfo();
      await startUserService();
      return true;
    }
    return false;
  }

  Future<ClientVO?> createClient(String uid, String token) async {
    var client = await readClientInfo(uid);
    if (client != null) {
      return client;
    }
    var result = await Dio().post("${AppConstants.apiUrl}/client/create",
        options: Options(
          headers: {
            "token": token,
          },
        ),
        data: {
          "systemType": Platform.operatingSystem,
          "systemVersion": Platform.operatingSystemVersion,
        });
    var data = result.data;
    if (data["msg"] == AppConstants.success) {
      var client = ClientVO.fromMap(data["data"]);
      saveClientInfo(uid, client);
      return client;
    }
    return null;
  }

  Future<void> startUserService() async {
    await readUserInfo();
  }

  Future<void> fetchUserInfo() async {
    var result = await Dio().post(
      "${AppConstants.apiUrl}/user/getUserInfo",
      options: Options(
        headers: {
          "token": token,
        },
      ),
    );
    var data = result.data;
    if (data["msg"] == AppConstants.success) {
      currentUser = UserVO.fromMap(data["data"]);
      client = await createClient("${currentUser?.id}", data['data']);
      await saveUserInfo();
      notifyListeners();
    }
  }

  Future<ClientVO?> readClientInfo(String? uid) async {
    if (uid == null || uid.isEmpty) {
      return null;
    }
    var info =
        await serviceManager.configManager.readConfig("client.$uid", "");
    if (info.isNotEmpty) {
      var client = ClientVO.fromMap(jsonDecode(info));
      if (client.id == null) {
        return null;
      }
      return client;
    }
    return null;
  }

  Future<void> saveClientInfo(String uid, ClientVO client) async {
    await serviceManager.configManager
        .saveConfig("client.$uid", jsonEncode(client.toMap()));
  }

  Future<void> readUserInfo() async {
    token = await serviceManager.configManager.readConfig("token", "");
    var info = await serviceManager.configManager.readConfig("currentUser", "");
    if (info.isNotEmpty) {
      currentUser = UserVO.fromMap(jsonDecode(info));
    }
    client = await readClientInfo("${currentUser?.id}");
    notifyListeners();
  }

  Future<void> saveUserInfo() async {
    serviceManager.configManager.saveConfig("token", token ?? "");
    var user = currentUser;
    if (user == null) {
      serviceManager.configManager.saveConfig("currentUser", "");
    } else {
      serviceManager.configManager
          .saveConfig("currentUser", jsonEncode(user.toMap()));
    }
  }

  Future<void> logout() async {
    currentUser = null;
    token = null;
    await saveUserInfo();
    //重新加载界面
    serviceManager.restartService();
    showToast("已退出登录！");
    notifyListeners();
  }

  Future<bool> sendSignCode(String email) async {
    try {
      var result = await Dio().post(
        "${AppConstants.apiUrl}/user/sendSignCode",
        data: {
          "email": email,
        },
        options: Options(contentType: "application/json"),
      );
      var data = result.data;
      if (data["msg"] == AppConstants.success) {
        return true;
      }
    } catch (e) {
      e.printError();
    }
    return false;
  }

  Future<bool> sign(String email, String emailCode, String password) async {
    try {
      var result = await Dio().post(
        "${AppConstants.apiUrl}/user/sign",
        data: {
          "email": email,
          "emailCode": emailCode,
          "password": password,
        },
        options: Options(contentType: "application/json"),
      );
      var data = result.data;
      if (data["msg"] == AppConstants.success) {
        return true;
      }
    } catch (e) {
      e.printError();
    }
    return false;
  }
}
