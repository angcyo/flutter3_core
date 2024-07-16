import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/16
///
/// 蒲公英上传脚本
/// https://www.pgyer.com/doc/view/api#fastUploadApp

const host = "https://www.pgyer.com";
const apiBase = "https://www.pgyer.com/apiv2/app";

void main(List<String> arguments) async {
  final currentPath = Directory.current.path;
  print('工作路径->$currentPath');
  final yamlFile = File("$currentPath/script.yaml");
  print('配置文件路径->${yamlFile.path}');

  final yaml = loadYaml(yamlFile.readAsStringSync());
  //print(yaml);

  final apiKey = yaml["pgyer_api_key"];

  for (final folder in yaml["pgyer_path"]) {
    print('开始上传文件夹->$folder');
    final fileList = await _getFileList(folder);
    for (final file in fileList) {
      final filePath = file.path;
      print('开始上传文件->$filePath');
      try {
        final buildType = filePath.endsWith(".apk")
            ? "android"
            : filePath.endsWith(".ipa")
                ? "ios"
                : null;
        if (buildType != null) {
          final tokenText = await _getCOSToken(apiKey, buildType,
              buildUpdateDescription: await _getVersionDes(folder));
          final tokenJson = jsonDecode(tokenText);
          final succeed = await _uploadAppFile(tokenJson["data"], file);
          if (succeed) {
            await _writeUploadRecord(folder, file);
            await _checkAppIsPublish(apiKey, tokenJson["data"]["key"]);
          }
        } else {
          print("不支持的文件->$filePath");
        }
      } catch (e) {
        print(e);
      }
    }
  }

  //await _checkAppIsPublish(apiKey, "123");
}

/// 获取指定目录下需要上传的文件列表
Future<List<File>> _getFileList(String folder) async {
  final result = <File>[];
  final dir = Directory(folder);
  if (await dir.exists()) {
    final recordText = await _readUploadRecord(folder);
    final files = dir.listSync();
    for (final file in files) {
      if (file is File) {
        final fileName = p.basename(file.path);
        if (fileName.endsWith(".apk") || fileName.endsWith(".ipa")) {
          final record = "$fileName/${file.lastModifiedSync()}";
          if (recordText.contains(record)) {
            print("跳过上传->$fileName");
            continue;
          }
          result.add(file);
        }
      }
    }
  }
  return result;
}

/// 在指定文件夹下, 读取上传记录内容
Future<String> _readUploadRecord(String folder) async {
  try {
    final uploadRecordFile = File("$folder/.upload");
    return uploadRecordFile.readAsStringSync();
  } catch (e) {
    return "";
  }
}

/// 写入指定记录
Future _writeUploadRecord(String folder, File file) async {
  final uploadRecordFile = File("$folder/.upload");
  if (!uploadRecordFile.existsSync()) {
    uploadRecordFile.parent.createSync(recursive: true);
    uploadRecordFile.createSync();
  }
  final fileName = p.basename(file.path);
  final record = "$fileName/${file.lastModifiedSync()}";
  await uploadRecordFile.writeAsString(record);
}

/// 在指定文件夹下, 读取版本更新描述内容
Future<String?> _getVersionDes(String folder) async {
  try {
    final file = File("$folder/version.json");
    final text = file.readAsStringSync();
    return jsonDecode(text)?["versionDes"];
  } catch (e) {
    return null;
  }
}

//---

/// 获取上传的token
///
///  [buildType]
/// (必填) 需要上传的应用类型，如果是iOS类型请传 ios或ipa
/// 如果是Android类型请传 android apk
///
Future<String> _getCOSToken(
  String apiKey,
  String buildType, {
  String? buildDescription,
  String? buildUpdateDescription,
}) async {
  const api = "$apiBase/getCOSToken";
  //post请求
  final postBody = {
    "_api_key": apiKey,
    "buildType": buildType,
    "buildInstallType": 1.toString(),
    "buildInstallDate": 2.toString(),
    "buildDescription": buildDescription,
    "buildUpdateDescription": buildUpdateDescription,
  }.removeAllNull();
  final response = await http.post(Uri.parse(api),
      body: postBody,
      headers: {"Content-Type": "application/x-www-form-urlencoded"});
  final body = response.body;
  print(body);
  return body;
}

/// 上传文件到第上一步获取的 URL
Future<bool> _uploadAppFile(dynamic tokenData, File file) async {
  final api = "${tokenData["endpoint"]}";
  //post请求 form-data 类型

  // 创建一个 MultipartRequest
  final request = http.MultipartRequest('POST', Uri.parse(api));

  // 添加 form-data 字段
  request.fields["key"] = tokenData["params"]["key"];
  request.fields["signature"] = tokenData["params"]["signature"];
  request.fields["x-cos-security-token"] =
      tokenData["params"]["x-cos-security-token"];

  // 添加文件字段
  final filePart = await http.MultipartFile.fromPath('file', file.path);
  request.files.add(filePart);

  // 发送请求并获取响应
  final response = await request.send();

  // 读取响应内容
  final responseBody = await response.stream.bytesToString();

  print(responseBody);
  if (response.statusCode == 204) {
    print("上传成功->${file.path}");
  }
  return response.statusCode == 204;
}

/// 检查应用是否发布
/// 如果返回 code = 1246 ，可间隔 3s ~ 5s 重新调用 URL 进行检测，直到返回成功或失败。
Future _checkAppIsPublish(String apiKey, String buildKey) async {
  const api = "$apiBase/buildInfo";
  //get请求
  final response = await http.get(Uri.parse(api).replace(queryParameters: {
    "_api_key": apiKey,
    "buildKey": buildKey,
  }));
  print(response.body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)?["data"];
    final buildShortcutUrl = data?["buildShortcutUrl"];
    if (buildShortcutUrl != null) {
      print("\n应用发布成功->$host/$buildShortcutUrl\n${data["buildQRCodeURL"]}");
    } else {
      //延迟3秒, 继续查询
      print('请稍等...');
      await Future.delayed(const Duration(seconds: 3));
      await _checkAppIsPublish(apiKey, buildKey);
    }
  }
}

extension MapEx<K, V> on Map<K, V> {
  /// 遍历移除所有value为null的key
  Map<K, V> removeAllNull([bool copy = false]) {
    final map = copy ? Map.from(this) : this;
    final keys = <K>[];
    map.forEach((key, value) {
      if (value == null) {
        keys.add(key);
      }
    });
    keys.forEach(map.remove);
    return map as Map<K, V>;
  }
}
