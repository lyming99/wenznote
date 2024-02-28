import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rich_clipboard/rich_clipboard.dart';
import 'package:uuid/uuid.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/block/image/image_element.dart';
import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:wenznote/service/service_manager.dart';

class CopyService {
  ServiceManager serviceManager;

  String? copyId;
  List<WenElement>? _copyElements;

  CopyService(this.serviceManager);

  String generateCopyId() {
    return const Uuid().v1();
  }

  List<WenElement>? get copyElements {
    return _cloneCopyElements();
  }

  List<WenElement>? _cloneCopyElements() {
    var elements = _copyElements;
    if (elements != null) {
      var result = <WenElement>[];
      for (var element in elements) {
        result.add(WenElement.parseJson(element.toJson()));
      }
      return result;
    }
    return null;
  }

  Future<void> saveCopyCache(BuildContext context, List<WenElement> elements,
      {String? copyId}) async {
    copyId ??= const Uuid().v1();
    this.copyId = copyId;
    _copyElements = elements;
    var copyContent = elements.map((e) => e.toJson()).toList();
    var map = {
      "copyId": copyId,
      "copyContent": jsonEncode(copyContent),
    };
    var saveJson = jsonEncode(map);
    var wenNoteDir = await serviceManager.fileManager.getWenNoteRootDir();
    File("$wenNoteDir/copyCache").writeAsString(saveJson);
  }

  Future<void> readCopyCache(BuildContext context) async {
    var wenNoteDir = await serviceManager.fileManager.getWenNoteRootDir();
    if (File("$wenNoteDir/copyCache").existsSync()) {
      var saveJson = await File("$wenNoteDir/copyCache").readAsString();
      Map content = jsonDecode(saveJson);
      copyId = content["copyId"];
      var copyContent = content["copyContent"] as String?;
      if (copyContent != null) {
        var copyElement = jsonDecode(copyContent) as List<dynamic>?;
        _copyElements =
            copyElement?.map((e) => WenElement.parseJson(e)).toList();
      }
    }
  }

  Future<void> copyDocContent(BuildContext context, String uuid) async {
    var copyId = generateCopyId();
    StringBuffer html = StringBuffer();
    html.writeln("<!DOCTYPE html>\n"
        "<html>\n<head>\n"
        "<meta charset=\"utf-8\"></meta></head><body copyid='$copyId'>");
    StringBuffer text = StringBuffer();
    var doc = await serviceManager.editService.readDoc(uuid);
    var copyElements = yDocToWenElements(doc);
    this.copyId = copyId;
    await saveCopyCache(context, copyElements, copyId: copyId);
    for (var element in copyElements) {
      text.writeln(element.getText());
      html.writeln(element.getHtml());
    }
    html.writeln("</body>");
    RichClipboard.setData(
        RichClipboardData(html: html.toString(), text: text.toString()));
  }

  Future<void> copyMarkdownContent(String uuid) async {
    StringBuffer markdown = StringBuffer();
    var doc = await serviceManager.editService.readDoc(uuid);
    var copyElements = yDocToWenElements(doc);
    for (var element in copyElements) {
      var filePath = "";
      if (element is WenImageElement) {
        var imageId = element.id;
        filePath = await serviceManager.fileManager.getImageFile(imageId) ?? "";
      }
      markdown.writeln(element.getMarkDown(filePathBuilder: (uuid) {
        return filePath;
      }));
    }
    await RichClipboard.setData(RichClipboardData(text: markdown.toString()));
  }

  Future<void> copyWenElements(
      BuildContext context, List<WenElement> copyElements,
      [bool copyPlanText = false]) async {
    var copyId = generateCopyId();
    StringBuffer html = StringBuffer();
    html.writeln("<!DOCTYPE html>\n"
        "<html>\n<head>\n"
        "<meta charset=\"utf-8\"></meta></head><body copyid='$copyId'>");
    StringBuffer text = StringBuffer();
    this.copyId = copyId;
    await saveCopyCache(context, copyElements, copyId: copyId);
    for (var element in copyElements) {
      text.writeln(element.getText());
      html.writeln(element.getHtml());
    }
    html.writeln("</body>");
    RichClipboard.setData(RichClipboardData(
        html: copyPlanText ? null : html.toString(), text: text.toString()));
  }
}
