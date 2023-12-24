// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_study_config_po.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCardStudyConfigPOCollection on Isar {
  IsarCollection<CardStudyConfigPO> get cardStudyConfigPOs => this.collection();
}

const CardStudyConfigPOSchema = CollectionSchema(
  name: r'CardStudyConfigPO',
  id: -3151375375473524086,
  properties: {
    r'cardSetId': PropertySchema(
      id: 0,
      name: r'cardSetId',
      type: IsarType.string,
    ),
    r'createBy': PropertySchema(
      id: 1,
      name: r'createBy',
      type: IsarType.string,
    ),
    r'createTime': PropertySchema(
      id: 2,
      name: r'createTime',
      type: IsarType.long,
    ),
    r'dailyReviewCount': PropertySchema(
      id: 3,
      name: r'dailyReviewCount',
      type: IsarType.long,
    ),
    r'dailyStudyCount': PropertySchema(
      id: 4,
      name: r'dailyStudyCount',
      type: IsarType.long,
    ),
    r'did': PropertySchema(
      id: 5,
      name: r'did',
      type: IsarType.string,
    ),
    r'hideTextMode': PropertySchema(
      id: 6,
      name: r'hideTextMode',
      type: IsarType.string,
    ),
    r'playTtsMode': PropertySchema(
      id: 7,
      name: r'playTtsMode',
      type: IsarType.string,
    ),
    r'reviewAlgorithm': PropertySchema(
      id: 8,
      name: r'reviewAlgorithm',
      type: IsarType.string,
    ),
    r'showMode': PropertySchema(
      id: 9,
      name: r'showMode',
      type: IsarType.string,
    ),
    r'studyOrderType': PropertySchema(
      id: 10,
      name: r'studyOrderType',
      type: IsarType.string,
    ),
    r'studyQueueMode': PropertySchema(
      id: 11,
      name: r'studyQueueMode',
      type: IsarType.string,
    ),
    r'ttsId': PropertySchema(
      id: 12,
      name: r'ttsId',
      type: IsarType.string,
    ),
    r'ttsType': PropertySchema(
      id: 13,
      name: r'ttsType',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(
      id: 14,
      name: r'uid',
      type: IsarType.string,
    ),
    r'updateBy': PropertySchema(
      id: 15,
      name: r'updateBy',
      type: IsarType.string,
    ),
    r'updateTime': PropertySchema(
      id: 16,
      name: r'updateTime',
      type: IsarType.long,
    ),
    r'uuid': PropertySchema(
      id: 17,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _cardStudyConfigPOEstimateSize,
  serialize: _cardStudyConfigPOSerialize,
  deserialize: _cardStudyConfigPODeserialize,
  deserializeProp: _cardStudyConfigPODeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _cardStudyConfigPOGetId,
  getLinks: _cardStudyConfigPOGetLinks,
  attach: _cardStudyConfigPOAttach,
  version: '3.1.0+1',
);

int _cardStudyConfigPOEstimateSize(
  CardStudyConfigPO object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cardSetId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.createBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.did;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.hideTextMode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.playTtsMode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reviewAlgorithm;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.showMode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.studyOrderType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.studyQueueMode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ttsId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ttsType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.uid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.updateBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.uuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cardStudyConfigPOSerialize(
  CardStudyConfigPO object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cardSetId);
  writer.writeString(offsets[1], object.createBy);
  writer.writeLong(offsets[2], object.createTime);
  writer.writeLong(offsets[3], object.dailyReviewCount);
  writer.writeLong(offsets[4], object.dailyStudyCount);
  writer.writeString(offsets[5], object.did);
  writer.writeString(offsets[6], object.hideTextMode);
  writer.writeString(offsets[7], object.playTtsMode);
  writer.writeString(offsets[8], object.reviewAlgorithm);
  writer.writeString(offsets[9], object.showMode);
  writer.writeString(offsets[10], object.studyOrderType);
  writer.writeString(offsets[11], object.studyQueueMode);
  writer.writeString(offsets[12], object.ttsId);
  writer.writeString(offsets[13], object.ttsType);
  writer.writeString(offsets[14], object.uid);
  writer.writeString(offsets[15], object.updateBy);
  writer.writeLong(offsets[16], object.updateTime);
  writer.writeString(offsets[17], object.uuid);
}

CardStudyConfigPO _cardStudyConfigPODeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CardStudyConfigPO(
    cardSetId: reader.readStringOrNull(offsets[0]),
    createBy: reader.readStringOrNull(offsets[1]),
    createTime: reader.readLongOrNull(offsets[2]),
    dailyReviewCount: reader.readLongOrNull(offsets[3]),
    dailyStudyCount: reader.readLongOrNull(offsets[4]),
    did: reader.readStringOrNull(offsets[5]),
    hideTextMode: reader.readStringOrNull(offsets[6]),
    id: id,
    playTtsMode: reader.readStringOrNull(offsets[7]),
    reviewAlgorithm: reader.readStringOrNull(offsets[8]),
    showMode: reader.readStringOrNull(offsets[9]),
    studyOrderType: reader.readStringOrNull(offsets[10]),
    studyQueueMode: reader.readStringOrNull(offsets[11]),
    ttsId: reader.readStringOrNull(offsets[12]),
    ttsType: reader.readStringOrNull(offsets[13]),
    uid: reader.readStringOrNull(offsets[14]),
    updateBy: reader.readStringOrNull(offsets[15]),
    updateTime: reader.readLongOrNull(offsets[16]),
    uuid: reader.readStringOrNull(offsets[17]),
  );
  return object;
}

P _cardStudyConfigPODeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cardStudyConfigPOGetId(CardStudyConfigPO object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cardStudyConfigPOGetLinks(
    CardStudyConfigPO object) {
  return [];
}

void _cardStudyConfigPOAttach(
    IsarCollection<dynamic> col, Id id, CardStudyConfigPO object) {
  object.id = id;
}

extension CardStudyConfigPOQueryWhereSort
    on QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QWhere> {
  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CardStudyConfigPOQueryWhere
    on QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QWhereClause> {
  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CardStudyConfigPOQueryFilter
    on QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QFilterCondition> {
  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cardSetId',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cardSetId',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardSetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardSetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardSetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardSetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cardSetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cardSetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardSetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardSetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardSetId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      cardSetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardSetId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createBy',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createBy',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      createTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyReviewCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dailyReviewCount',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyReviewCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dailyReviewCount',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyReviewCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyReviewCountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyReviewCountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyReviewCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyReviewCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyStudyCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dailyStudyCount',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyStudyCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dailyStudyCount',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyStudyCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyStudyCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyStudyCountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyStudyCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyStudyCountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyStudyCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      dailyStudyCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyStudyCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'did',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'did',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'did',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'did',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      didIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hideTextMode',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hideTextMode',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hideTextMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hideTextMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hideTextMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hideTextMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hideTextMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hideTextMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hideTextMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hideTextMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hideTextMode',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      hideTextModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hideTextMode',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playTtsMode',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playTtsMode',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playTtsMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playTtsMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playTtsMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playTtsMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playTtsMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playTtsMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playTtsMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playTtsMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playTtsMode',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      playTtsModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playTtsMode',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reviewAlgorithm',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reviewAlgorithm',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewAlgorithm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewAlgorithm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewAlgorithm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewAlgorithm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reviewAlgorithm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reviewAlgorithm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reviewAlgorithm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reviewAlgorithm',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewAlgorithm',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      reviewAlgorithmIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reviewAlgorithm',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'showMode',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'showMode',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'showMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'showMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'showMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'showMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'showMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'showMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'showMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showMode',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      showModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'showMode',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'studyOrderType',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'studyOrderType',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studyOrderType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'studyOrderType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'studyOrderType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'studyOrderType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'studyOrderType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'studyOrderType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studyOrderType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studyOrderType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studyOrderType',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyOrderTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studyOrderType',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'studyQueueMode',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'studyQueueMode',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studyQueueMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'studyQueueMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'studyQueueMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'studyQueueMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'studyQueueMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'studyQueueMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studyQueueMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studyQueueMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studyQueueMode',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      studyQueueModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studyQueueMode',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ttsId',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ttsId',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ttsId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ttsId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ttsId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ttsId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ttsId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ttsId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ttsId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ttsId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ttsId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ttsId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ttsType',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ttsType',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ttsType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ttsType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ttsType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ttsType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ttsType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ttsType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ttsType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ttsType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ttsType',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      ttsTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ttsType',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uid',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uid',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updateBy',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updateBy',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updateBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updateBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updateBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'updateBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'updateBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'updateBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'updateBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'updateBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      updateTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uuid',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uuid',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension CardStudyConfigPOQueryObject
    on QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QFilterCondition> {}

extension CardStudyConfigPOQueryLinks
    on QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QFilterCondition> {}

extension CardStudyConfigPOQuerySortBy
    on QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QSortBy> {
  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByCardSetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByCardSetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByCreateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByCreateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByDailyReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReviewCount', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByDailyReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReviewCount', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByDailyStudyCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyStudyCount', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByDailyStudyCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyStudyCount', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy> sortByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByHideTextMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideTextMode', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByHideTextModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideTextMode', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByPlayTtsMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playTtsMode', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByPlayTtsModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playTtsMode', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByReviewAlgorithm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewAlgorithm', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByReviewAlgorithmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewAlgorithm', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByShowMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showMode', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByShowModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showMode', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByStudyOrderType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyOrderType', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByStudyOrderTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyOrderType', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByStudyQueueMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyQueueMode', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByStudyQueueModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyQueueMode', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByTtsId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttsId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByTtsIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttsId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByTtsType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttsType', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByTtsTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttsType', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByUpdateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByUpdateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension CardStudyConfigPOQuerySortThenBy
    on QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QSortThenBy> {
  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByCardSetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByCardSetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByCreateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByCreateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByDailyReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReviewCount', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByDailyReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReviewCount', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByDailyStudyCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyStudyCount', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByDailyStudyCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyStudyCount', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy> thenByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByHideTextMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideTextMode', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByHideTextModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideTextMode', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByPlayTtsMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playTtsMode', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByPlayTtsModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playTtsMode', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByReviewAlgorithm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewAlgorithm', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByReviewAlgorithmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewAlgorithm', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByShowMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showMode', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByShowModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showMode', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByStudyOrderType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyOrderType', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByStudyOrderTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyOrderType', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByStudyQueueMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyQueueMode', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByStudyQueueModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyQueueMode', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByTtsId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttsId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByTtsIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttsId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByTtsType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttsType', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByTtsTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttsType', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByUpdateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByUpdateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension CardStudyConfigPOQueryWhereDistinct
    on QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct> {
  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByCardSetId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardSetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByCreateBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createTime');
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByDailyReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyReviewCount');
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByDailyStudyCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyStudyCount');
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct> distinctByDid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'did', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByHideTextMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hideTextMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByPlayTtsMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playTtsMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByReviewAlgorithm({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewAlgorithm',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByShowMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByStudyOrderType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studyOrderType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByStudyQueueMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studyQueueMode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct> distinctByTtsId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ttsId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByTtsType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ttsType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByUpdateBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct>
      distinctByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateTime');
    });
  }

  QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension CardStudyConfigPOQueryProperty
    on QueryBuilder<CardStudyConfigPO, CardStudyConfigPO, QQueryProperty> {
  QueryBuilder<CardStudyConfigPO, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations>
      cardSetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardSetId');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations>
      createByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createBy');
    });
  }

  QueryBuilder<CardStudyConfigPO, int?, QQueryOperations> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createTime');
    });
  }

  QueryBuilder<CardStudyConfigPO, int?, QQueryOperations>
      dailyReviewCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyReviewCount');
    });
  }

  QueryBuilder<CardStudyConfigPO, int?, QQueryOperations>
      dailyStudyCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyStudyCount');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations> didProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'did');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations>
      hideTextModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hideTextMode');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations>
      playTtsModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playTtsMode');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations>
      reviewAlgorithmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewAlgorithm');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations>
      showModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showMode');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations>
      studyOrderTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studyOrderType');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations>
      studyQueueModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studyQueueMode');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations> ttsIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ttsId');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations> ttsTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ttsType');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations>
      updateByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateBy');
    });
  }

  QueryBuilder<CardStudyConfigPO, int?, QQueryOperations> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateTime');
    });
  }

  QueryBuilder<CardStudyConfigPO, String?, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
