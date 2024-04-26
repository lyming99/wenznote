import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:octo_image/octo_image.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wenznote/commons/util/file_utils.dart';
import 'package:wenznote/config/app_constants.dart';
import 'package:wenznote/editor/block/image/multi_source_file_image.dart';
import 'package:wenznote/model/client/client_vo.dart';
import 'package:wenznote/model/client/server_vo.dart';
import 'package:wenznote/model/user/user_vo.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:ydart/utils/y_doc.dart';

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
  ServerVO? noteServer;

  UserService(this.serviceManager);

  bool get hasLogin => currentUser != null;

  String get userPath {
    return currentUser == null ? "user-local/" : "user-${currentUser!.id}/";
  }

  Dio get dio {
    var options = BaseOptions(headers: {"token": token});
    var dio = Dio(options);
    return dio;
  }

  int? get uid => currentUser?.id;

  int get clientId => client?.id ?? YDoc.generateNewClientId();

  String? get noteServerUrl {
    var noteServer = this.noteServer;
    if (noteServer == null) {
      return null;
    }
    return "http://${noteServer.host}:${noteServer.port}";
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (Platform.isIOS) {
      await Permission.appTrackingTransparency.request();
    }
    //1.调用接口登录
    //2.将token保存到本地
    //3.将用户信息保存到本地
    //4.如果是首次登录，则提示用户是否将本地离线数据导入
    try {
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
    } catch (e) {
      print(e);
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
      await saveClientInfo(uid, client);
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
      currentUser = UserVO.fromMap(data["data"] ?? "{}");
      client = await createClient("${currentUser?.id}", token ?? "");
      noteServer = await queryNoteServer();
      await saveUserInfo();
      notifyListeners();
    }
  }

  Future<ServerVO?> queryNoteServer() async {
    var result = await Dio().post(
      "${AppConstants.apiUrl}/server/queryNoteServer",
      options: Options(
        headers: {
          "token": token,
        },
      ),
    );
    var data = result.data;
    if (data['msg'] == AppConstants.success) {
      return ServerVO.fromMap(data['data']);
    }
    return null;
  }

  Future<ClientVO?> readClientInfo(String? uid) async {
    if (uid == null || uid.isEmpty) {
      return null;
    }
    var info = await serviceManager.configManager.readConfig("client.$uid", "");
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
    if ((token ?? "").isEmpty) {
      currentUser = null;
      client = null;
      noteServer = null;
      return;
    }
    var info = await serviceManager.configManager.readConfig("currentUser", "");
    if (info.isNotEmpty) {
      currentUser = UserVO.fromMap(jsonDecode(info));
    }
    client = await readClientInfo("${currentUser?.id}");
    noteServer = await queryNoteServer();
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

  Future<void> clearUserInfo() async {
    serviceManager.configManager.saveConfig("token", "");
    serviceManager.configManager.saveConfig("currentUser", "");
  }

  Future<void> logout() async {
    await clearUserInfo();
    await sendLogout();
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

  Future<bool> updateSign(String content) async {
    try {
      var result = await Dio().post(
        "${AppConstants.apiUrl}/user/editSign",
        data: {
          "sign": content,
        },
        options: Options(
          contentType: "application/json",
          headers: {
            "token": token,
          },
        ),
      );
      var data = result.data;
      if (data["msg"] == AppConstants.success) {
        await fetchUserInfo();
        return true;
      }
    } catch (e) {
      e.printError();
    }
    return false;
  }

  Future<bool> updateAvatar(String path) async {
    try {
      var result = await Dio().post(
        "${AppConstants.apiUrl}/user/editAvatar",
        data: FormData.fromMap({
          "file":
              await MultipartFile.fromFile(path, filename: getFileName(path)),
        }),
        options: Options(
          contentType: "application/json",
          headers: {
            "token": token,
            "Content-Type": "multipart/form-data;",
          },
          responseType: ResponseType.json,
        ),
      );
      var data = result.data;
      if (data["msg"] == AppConstants.success) {
        await fetchUserInfo();
        await downloadAvatar();
        return true;
      }
    } catch (e) {
      e.printError();
    }
    return false;
  }

  Future<void> downloadAvatar() async {
    var avatarFile = await getAvatarFile();
    bool exist = File(avatarFile).existsSync();
    if (exist) {
      return;
    }
    await Dio().download(
      "${AppConstants.apiUrl}/file/downloadAvatar",
      avatarFile,
      options: Options(
        headers: {
          "token": token,
        },
      ),
    );
    notifyListeners();
  }

  Widget defaultUserIcon(double size) {
    return Icon(
      Icons.account_circle,
      size: 32,
      color: Colors.grey.shade600,
    );
  }

  Widget buildUserIcon(
    BuildContext context, [
    double size = 32,
  ]) {
    var userService = serviceManager.userService;
    var imageId = userService.currentUser?.avatar;
    if (imageId == null) {
      return defaultUserIcon(size);
    }
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size),
        ),
        clipBehavior: Clip.antiAlias,
        child: OctoImage(
          color: null,
          placeholderBuilder: (context) => defaultUserIcon(size),
          image: MultiSourceFileImage(
              imageId: imageId,
              reader: (id) async {
                await userService.downloadAvatar();
                var file = await userService.getAvatarFile();
                return File(file).readAsBytes();
              }),
        ),
      ),
    );
  }

  Future<String> getAvatarFile() async {
    var downloadDir = await serviceManager.fileManager.getDownloadDir();
    return "$downloadDir/${currentUser?.avatar}";
  }

  Future<bool> updateNickname(String content) async {
    try {
      var result = await Dio().post(
        "${AppConstants.apiUrl}/user/editNickname",
        data: {
          "nickname": content,
        },
        options: Options(
          contentType: "application/json",
          headers: {
            "token": token,
          },
        ),
      );
      var data = result.data;
      if (data["msg"] == AppConstants.success) {
        await fetchUserInfo();
        return true;
      }
    } catch (e) {
      e.printError();
    }
    return false;
  }

  Future<bool> updatePassword(
      String email, String emailCode, String password) async {
    try {
      var result = await Dio().post(
        "${AppConstants.apiUrl}/user/forgetPassword",
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

  Future<bool> sendLogout() async {
    try {
      var result = await Dio().post(
        "${AppConstants.apiUrl}/user/logout",
        options: Options(
          contentType: "application/json",
          headers: {
            "token": token,
          },
        ),
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

  Future<bool> cKeyRecharge(String cKey) async {
    try {
      var result = await Dio().post(
        "${AppConstants.apiUrl}/ckey/rechargeVip",
        data: {
          "cKey": cKey,
        },
        options: Options(
          contentType: "application/json",
          headers: {
            "token": token,
          },
        ),
      );
      var data = result.data;
      if (data["msg"] == AppConstants.success) {
        await fetchUserInfo();
        return true;
      }
    } catch (e) {
      e.printError();
    }
    return false;
  }

  String getVipInfo() {
    var infoList = currentUser?.vipInfoList;
    if (infoList == null || infoList.isEmpty) {
      return "已过期";
    }
    var isForever = infoList
        .where((element) =>
            element.vipType == 'vip' && element.limitTimeType == 'no_limit')
        .isNotEmpty;
    if (isForever) {
      return "终身学习";
    }
    var maxTime = DateTime.now();
    for (var info in infoList.where((element) => element.vipType == "vip")) {
      var startTime = info.startTime;
      var endTime = info.endTime;
      if (startTime == null || endTime == null) {
        continue;
      }
      if (maxTime.isBefore(endTime)) {
        maxTime = endTime;
      }
    }
    var now = DateTime.now();
    if (now.isBefore(maxTime)) {
      var diff = maxTime.difference(now);
      var days = diff.inDays;
      var hours = diff.inHours;
      var minutes = diff.inMinutes;
      if (days > 0) {
        return "剩余 $days 天";
      } else if (hours > 0) {
        return "剩余 $hours 小时";
      } else if (minutes > 0) {
        return "剩余 $minutes 分钟";
      }
    }
    return "已过期";
  }
}
