import 'dart:math';

import 'package:isar/isar.dart';
import 'package:note/commons/util/date_util.dart';
import 'package:note/model/card/po/card_po.dart';
import 'package:note/model/card/po/card_study_config_po.dart';
import 'package:note/model/card/po/card_study_queue_po.dart';
import 'package:note/model/card/po/card_study_record_po.dart';
import 'package:note/model/note/vo/xy_item.dart';
import 'package:note/service/isar/isar_service_mixin.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/service/task/task.dart';
import 'package:uuid/uuid.dart';

class CardStudyService with IsarServiceMixin {
  @override
  ServiceManager serviceManager;

  CardStudyService(this.serviceManager);

  Future<CardStudyConfigPO?> queryStudyConfig(String? uuid) async {
    return documentIsar.cardStudyConfigPOs
        .filter()
        .cardSetIdEqualTo(uuid)
        .findFirst();
  }

  Future<void> saveStudyConfig(CardStudyConfigPO config) async {
    await documentIsar.writeTxn(() async {
      documentIsar.cardStudyConfigPOs.put(config);
    });
  }

  Future<void> _generateStudyQueue(String? cardSetId) async {
    if (cardSetId == null) {
      return;
    }
    var config = await queryStudyConfig(cardSetId);
    var studyQueueCount = config?.dailyStudyCount ?? 100;
    var dayMill = 24 * 60 * 60 * 1000;
    var now = DateTime.now().millisecondsSinceEpoch;
    var mod = now % dayMill;
    int dayStart = now - mod;
    int dayEnd = dayStart + dayMill - 1;
    var count = documentIsar.cardStudyQueuePOs
        .filter()
        .cardSetIdEqualTo(cardSetId)
        .createTimeBetween(dayStart, dayEnd)
        .countSync();
    var generateCount = studyQueueCount - count;
    if (generateCount <= 0) {
      return;
    }
    var cardList =
        documentIsar.cardPOs.filter().cardSetIdEqualTo(cardSetId).findAllSync();
    var studyQueue = documentIsar.cardStudyQueuePOs
        .filter()
        .cardSetIdEqualTo(cardSetId)
        .createTimeBetween(dayStart, dayEnd)
        .cardIdProperty()
        .findAllSync()
        .toSet();
    var studyRecord = documentIsar.cardStudyRecordPOs
        .filter()
        .cardSetIdEqualTo(cardSetId)
        .cardIdProperty()
        .findAllSync()
        .toSet();
    cardList.removeWhere((element) =>
        studyRecord.contains(element.uuid) ||
        studyQueue.contains(element.uuid));
    List<CardPO> studyList;
    if (config?.studyOrderType == "random") {
      //随机取出
      studyList = [];
      var random = Random();
      for (var i = 0; i < generateCount && cardList.isNotEmpty; i++) {
        studyList.add(cardList.removeAt(random.nextInt(cardList.length)));
      }
    } else {
      //按创建日期排序取出
      cardList.sort((a, b) => (a.createTime ?? 0).compareTo(b.createTime ?? 0));
      studyList = cardList.sublist(0, min(cardList.length, generateCount));
    }
    List<CardStudyQueuePO> queue = [];
    var orderIndex = 0;
    for (var value in studyList) {
      queue.add(
        CardStudyQueuePO(
          uuid: const Uuid().v1(),
          cardSetId: cardSetId,
          cardId: value.uuid,
          orderIndex: orderIndex++,
          createTime: now,
          updateTime: now,
        ),
      );
    }
    await documentIsar.writeTxn(() async {
      await documentIsar.cardStudyQueuePOs.putAll(queue);
    });
  }

  Future<void> generateStudyQueue(String? cardSetId) async {
    await TaskService.instance.executeTask(
      taskGroup: "generateStudyQueue",
      task: () async {
        await _generateStudyQueue(cardSetId);
      },
    );
  }

  Future<void> createStudyRecord(CardStudyRecordPO record) async {
    await documentIsar.writeTxn(() async {
      await documentIsar.cardStudyRecordPOs.put(record);
    });
  }

  Future<Set<String>> queryCardIdSet(String? cardSetId) async {
    return documentIsar.cardPOs
        .filter()
        .cardSetIdEqualTo(cardSetId)
        .uuidIsNotNull()
        .uuidProperty()
        .findAllSync()
        .map((e) => e!)
        .toSet();
  }

  Future<int> queryTodayStudyCount(String? cardSetId) async {
    var cardIdSet = await queryCardIdSet(cardSetId);
    var dayMill = 24 * 60 * 60 * 1000;
    var now = DateTime.now().millisecondsSinceEpoch;
    var mod = now % dayMill;
    int dayStart = now - mod;
    int dayEnd = dayStart + dayMill - 1;
    var studyQueue = documentIsar.cardStudyQueuePOs
        .filter()
        .cardSetIdEqualTo(cardSetId)
        .createTimeBetween(dayStart, dayEnd)
        .sortByCreateTime()
        .thenByOrderIndex()
        .cardIdProperty()
        .findAllSync()
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
    var studyRecord = documentIsar.cardStudyRecordPOs
        .filter()
        .createTimeBetween(dayStart, dayEnd)
        .cardSetIdEqualTo(cardSetId)
        .cardIdProperty()
        .findAllSync()
        .toSet();
    studyQueue.removeWhere((element) => !studyRecord.contains(element));
    studyQueue.removeWhere((element) => !cardIdSet.contains(element));
    return studyQueue.length;
  }

  Future<int> queryTodayStudyQueueCount(String? cardSetId) async {
    var cardIdSet = await queryCardIdSet(cardSetId);
    var dayMill = 24 * 60 * 60 * 1000;
    var now = DateTime.now().millisecondsSinceEpoch;
    var mod = now % dayMill;
    int dayStart = now - mod;
    int dayEnd = dayStart + dayMill - 1;
    var queue = documentIsar.cardStudyQueuePOs
        .filter()
        .cardSetIdEqualTo(cardSetId)
        .createTimeBetween(dayStart, dayEnd)
        .cardIdProperty()
        .findAllSync();
    queue.removeWhere((element) => !cardIdSet.contains(element));
    return queue.length;
  }

  Future<List<String>> queryNeedStudyQueue(String? cardSetId) async {
    var dayMill = 24 * 60 * 60 * 1000;
    var now = DateTime.now().millisecondsSinceEpoch;
    var mod = now % dayMill;
    int dayStart = now - mod;
    int dayEnd = dayStart + dayMill - 1;
    var studyQueue = documentIsar.cardStudyQueuePOs
        .filter()
        .cardSetIdEqualTo(cardSetId)
        .createTimeBetween(dayStart, dayEnd)
        .sortByCreateTime()
        .thenByOrderIndex()
        .cardIdProperty()
        .findAllSync()
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
    //在这里，进行查询今日学习？
    var studyRecord = documentIsar.cardStudyRecordPOs
        .filter()
        .cardSetIdEqualTo(cardSetId)
        .cardIdProperty()
        .findAllSync()
        .toSet();
    studyQueue.removeWhere((element) => studyRecord.contains(element));
    var cardIdSet = await queryCardIdSet(cardSetId);
    studyQueue.removeWhere((element) => !cardIdSet.contains(element));
    return studyQueue;
  }

  Future<List<String>> queryTodayStudyQueue(String? cardSetId) async {
    var dayMill = 24 * 60 * 60 * 1000;
    var now = DateTime.now().millisecondsSinceEpoch;
    var mod = now % dayMill;
    int dayStart = now - mod;
    int dayEnd = dayStart + dayMill - 1;
    var studyQueue = documentIsar.cardStudyQueuePOs
        .filter()
        .cardSetIdEqualTo(cardSetId)
        .createTimeBetween(dayStart, dayEnd)
        .sortByCreateTime()
        .thenByOrderIndex()
        .cardIdProperty()
        .findAllSync()
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
    var cardIdSet = await queryCardIdSet(cardSetId);
    studyQueue.removeWhere((element) => !cardIdSet.contains(element));
    return studyQueue;
  }

  Future<List<String>> queryReviewQueue(String? cardSetId) async {
    var all = documentIsar.cardStudyRecordPOs
        .filter()
        .cardSetIdEqualTo(cardSetId)
        .findAllSync();
    var studyRecordMap = <String, CardStudyRecordPO>{};
    for (var value in all) {
      studyRecordMap.update(
        value.cardId ?? "",
        (current) {
          if ((current.nextStudyTime ?? 0) < (value.nextStudyTime ?? 0)) {
            return value;
          }
          return current;
        },
        ifAbsent: () {
          return value;
        },
      );
    }
    var reviewList = studyRecordMap.values
        .where((element) =>
            element.nextStudyTime != null &&
            element.cardId != null &&
            (element.nextStudyTime!) < DateTime.now().millisecondsSinceEpoch)
        .map((e) => e.cardId!)
        .toList();

    var cardIdSet = await queryCardIdSet(cardSetId);
    reviewList.removeWhere((element) => !cardIdSet.contains(element));
    return reviewList;
  }

  Future<CardStudyRecordPO?> queryStudyRecord(String? uuid) async {
    if (uuid == null) {
      return null;
    }
    return documentIsar.cardStudyRecordPOs
        .filter()
        .cardIdEqualTo(uuid)
        .sortByCreateByDesc()
        .limit(1)
        .findFirstSync();
  }

  Future<List<XYItem<String, int>>> queryStudyCountGraphx(
      String? cardSetId) async {
    List<XYItem<String, int>> result = [];
    if (cardSetId == null) {
      return result;
    }
    // 查询最近30天的数据
    var now = DateTime.now();
    for (var i = 0; i < 30; i++) {
      var dayStart = DateUtil.dayStart(now.millisecondsSinceEpoch);
      var dayEnd = DateUtil.dayEnd(now.millisecondsSinceEpoch);
      var studyRecords = documentIsar.cardStudyRecordPOs
          .filter()
          .cardSetIdEqualTo(cardSetId)
          .createTimeBetween(dayStart, dayEnd)
          .distinctByCardId()
          .findAllSync();
      int studyCount = 0;
      for (var record in studyRecords) {
        var find = documentIsar.cardStudyRecordPOs
            .filter()
            .cardIdEqualTo(record.cardId)
            .createTimeLessThan(dayStart)
            .findFirstSync();
        if (find != null) {
          continue;
        }
        studyCount++;
      }
      var date = DateUtil.dateToMd(now);
      result.add(XYItem(x: date, y: studyCount));
      now = DateUtil.addDays(now, -1);
    }
    return result.reversed.toList();
  }

  Future<List<XYItem<String, int>>> queryReviewCountGraphx(
      String? cardSetId) async {
    List<XYItem<String, int>> result = [];
    if (cardSetId == null) {
      return result;
    }
    // 查询最近30天的数据
    var now = DateTime.now();
    for (var i = 0; i < 30; i++) {
      var dayStart = DateUtil.dayStart(now.millisecondsSinceEpoch);
      var dayEnd = DateUtil.dayEnd(now.millisecondsSinceEpoch);
      var studyRecords = documentIsar.cardStudyRecordPOs
          .filter()
          .cardSetIdEqualTo(cardSetId)
          .createTimeBetween(dayStart, dayEnd)
          .distinctByCardId()
          .findAllSync();
      int studyCount = 0;
      for (var record in studyRecords) {
        var find = documentIsar.cardStudyRecordPOs
            .filter()
            .cardIdEqualTo(record.cardId)
            .createTimeLessThan(dayStart)
            .findFirstSync();
        if (find == null) {
          continue;
        }
        studyCount++;
      }
      var date = DateUtil.dateToMd(now);
      result.add(XYItem(x: date, y: studyCount));
      now = DateUtil.addDays(now, -1);
    }
    return result.reversed.toList();
  }

  Future<List<XYItem<String, int>>> queryStudyTimeGraphx(
      String? cardSetId) async {
    List<XYItem<String, int>> result = [];
    if (cardSetId == null) {
      return result;
    }
    // 查询最近30天的数据
    var now = DateTime.now();
    for (var i = 0; i < 30; i++) {
      var dayStart = DateUtil.dayStart(now.millisecondsSinceEpoch);
      var dayEnd = DateUtil.dayEnd(now.millisecondsSinceEpoch);
      var studyRecords = documentIsar.cardStudyRecordPOs
          .filter()
          .cardSetIdEqualTo(cardSetId)
          .createTimeBetween(dayStart, dayEnd)
          .findAllSync();
      int studyTime = 0;
      for (var value in studyRecords) {
        studyTime += max(0, (value.endTime ?? 0) - (value.startTime ?? 0));
      }
      var date = DateUtil.dateToMd(now);
      result.add(XYItem(x: date, y: studyTime));
      now = DateUtil.addDays(now, -1);
    }
    return result.reversed.toList();
  }
}
