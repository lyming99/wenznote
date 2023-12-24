// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_study_record_po.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCardStudyRecordPOCollection on Isar {
  IsarCollection<CardStudyRecordPO> get cardStudyRecordPOs => this.collection();
}

const CardStudyRecordPOSchema = CollectionSchema(
  name: r'CardStudyRecordPO',
  id: 5263811551878958593,
  properties: {
    r'cardId': PropertySchema(
      id: 0,
      name: r'cardId',
      type: IsarType.string,
    ),
    r'cardSetId': PropertySchema(
      id: 1,
      name: r'cardSetId',
      type: IsarType.string,
    ),
    r'createBy': PropertySchema(
      id: 2,
      name: r'createBy',
      type: IsarType.string,
    ),
    r'createTime': PropertySchema(
      id: 3,
      name: r'createTime',
      type: IsarType.long,
    ),
    r'did': PropertySchema(
      id: 4,
      name: r'did',
      type: IsarType.string,
    ),
    r'endTime': PropertySchema(
      id: 5,
      name: r'endTime',
      type: IsarType.long,
    ),
    r'fsrsRemInfo': PropertySchema(
      id: 6,
      name: r'fsrsRemInfo',
      type: IsarType.string,
    ),
    r'nextStudyTime': PropertySchema(
      id: 7,
      name: r'nextStudyTime',
      type: IsarType.long,
    ),
    r'score': PropertySchema(
      id: 8,
      name: r'score',
      type: IsarType.long,
    ),
    r'startTime': PropertySchema(
      id: 9,
      name: r'startTime',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(
      id: 10,
      name: r'uid',
      type: IsarType.string,
    ),
    r'updateBy': PropertySchema(
      id: 11,
      name: r'updateBy',
      type: IsarType.string,
    ),
    r'updateTime': PropertySchema(
      id: 12,
      name: r'updateTime',
      type: IsarType.long,
    ),
    r'uuid': PropertySchema(
      id: 13,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _cardStudyRecordPOEstimateSize,
  serialize: _cardStudyRecordPOSerialize,
  deserialize: _cardStudyRecordPODeserialize,
  deserializeProp: _cardStudyRecordPODeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _cardStudyRecordPOGetId,
  getLinks: _cardStudyRecordPOGetLinks,
  attach: _cardStudyRecordPOAttach,
  version: '3.1.0+1',
);

int _cardStudyRecordPOEstimateSize(
  CardStudyRecordPO object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cardId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
    final value = object.fsrsRemInfo;
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

void _cardStudyRecordPOSerialize(
  CardStudyRecordPO object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cardId);
  writer.writeString(offsets[1], object.cardSetId);
  writer.writeString(offsets[2], object.createBy);
  writer.writeLong(offsets[3], object.createTime);
  writer.writeString(offsets[4], object.did);
  writer.writeLong(offsets[5], object.endTime);
  writer.writeString(offsets[6], object.fsrsRemInfo);
  writer.writeLong(offsets[7], object.nextStudyTime);
  writer.writeLong(offsets[8], object.score);
  writer.writeLong(offsets[9], object.startTime);
  writer.writeString(offsets[10], object.uid);
  writer.writeString(offsets[11], object.updateBy);
  writer.writeLong(offsets[12], object.updateTime);
  writer.writeString(offsets[13], object.uuid);
}

CardStudyRecordPO _cardStudyRecordPODeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CardStudyRecordPO(
    cardId: reader.readStringOrNull(offsets[0]),
    cardSetId: reader.readStringOrNull(offsets[1]),
    createBy: reader.readStringOrNull(offsets[2]),
    createTime: reader.readLongOrNull(offsets[3]),
    did: reader.readStringOrNull(offsets[4]),
    endTime: reader.readLongOrNull(offsets[5]),
    fsrsRemInfo: reader.readStringOrNull(offsets[6]),
    id: id,
    nextStudyTime: reader.readLongOrNull(offsets[7]),
    score: reader.readLongOrNull(offsets[8]),
    startTime: reader.readLongOrNull(offsets[9]),
    uid: reader.readStringOrNull(offsets[10]),
    updateBy: reader.readStringOrNull(offsets[11]),
    updateTime: reader.readLongOrNull(offsets[12]),
    uuid: reader.readStringOrNull(offsets[13]),
  );
  return object;
}

P _cardStudyRecordPODeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cardStudyRecordPOGetId(CardStudyRecordPO object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cardStudyRecordPOGetLinks(
    CardStudyRecordPO object) {
  return [];
}

void _cardStudyRecordPOAttach(
    IsarCollection<dynamic> col, Id id, CardStudyRecordPO object) {
  object.id = id;
}

extension CardStudyRecordPOQueryWhereSort
    on QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QWhere> {
  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CardStudyRecordPOQueryWhere
    on QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QWhereClause> {
  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterWhereClause>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterWhereClause>
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

extension CardStudyRecordPOQueryFilter
    on QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QFilterCondition> {
  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cardId',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cardId',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardSetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cardSetId',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardSetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cardSetId',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardSetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardSetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardSetIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardSetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardSetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardSetId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      cardSetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardSetId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      createByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createBy',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      createByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createBy',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      createByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      createByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      createByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      createByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      createTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      createTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      createTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      didIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'did',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      didIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'did',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      didContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      didMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'did',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      didIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      didIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      endTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      endTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      endTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      endTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fsrsRemInfo',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fsrsRemInfo',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fsrsRemInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fsrsRemInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fsrsRemInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fsrsRemInfo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fsrsRemInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fsrsRemInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fsrsRemInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fsrsRemInfo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fsrsRemInfo',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      fsrsRemInfoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fsrsRemInfo',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      nextStudyTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextStudyTime',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      nextStudyTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextStudyTime',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      nextStudyTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextStudyTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      nextStudyTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextStudyTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      nextStudyTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextStudyTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      nextStudyTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextStudyTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      scoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'score',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      scoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'score',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      scoreEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      scoreGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      scoreLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      scoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      startTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startTime',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      startTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startTime',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      startTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      startTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      startTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      startTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uid',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uid',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      updateByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updateBy',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      updateByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updateBy',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      updateByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'updateBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      updateByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'updateBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      updateByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      updateByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'updateBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      updateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      updateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      updateTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uuid',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uuid',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension CardStudyRecordPOQueryObject
    on QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QFilterCondition> {}

extension CardStudyRecordPOQueryLinks
    on QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QFilterCondition> {}

extension CardStudyRecordPOQuerySortBy
    on QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QSortBy> {
  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByCardSetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByCardSetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByCreateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByCreateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy> sortByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByFsrsRemInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fsrsRemInfo', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByFsrsRemInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fsrsRemInfo', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByNextStudyTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextStudyTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByNextStudyTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextStudyTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByUpdateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByUpdateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension CardStudyRecordPOQuerySortThenBy
    on QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QSortThenBy> {
  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByCardSetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByCardSetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByCreateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByCreateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy> thenByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByFsrsRemInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fsrsRemInfo', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByFsrsRemInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fsrsRemInfo', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByNextStudyTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextStudyTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByNextStudyTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextStudyTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByUpdateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByUpdateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension CardStudyRecordPOQueryWhereDistinct
    on QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct> {
  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByCardId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByCardSetId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardSetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByCreateBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createTime');
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct> distinctByDid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'did', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByFsrsRemInfo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fsrsRemInfo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByNextStudyTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextStudyTime');
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByUpdateBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct>
      distinctByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateTime');
    });
  }

  QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension CardStudyRecordPOQueryProperty
    on QueryBuilder<CardStudyRecordPO, CardStudyRecordPO, QQueryProperty> {
  QueryBuilder<CardStudyRecordPO, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CardStudyRecordPO, String?, QQueryOperations> cardIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardId');
    });
  }

  QueryBuilder<CardStudyRecordPO, String?, QQueryOperations>
      cardSetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardSetId');
    });
  }

  QueryBuilder<CardStudyRecordPO, String?, QQueryOperations>
      createByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createBy');
    });
  }

  QueryBuilder<CardStudyRecordPO, int?, QQueryOperations> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createTime');
    });
  }

  QueryBuilder<CardStudyRecordPO, String?, QQueryOperations> didProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'did');
    });
  }

  QueryBuilder<CardStudyRecordPO, int?, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<CardStudyRecordPO, String?, QQueryOperations>
      fsrsRemInfoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fsrsRemInfo');
    });
  }

  QueryBuilder<CardStudyRecordPO, int?, QQueryOperations>
      nextStudyTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextStudyTime');
    });
  }

  QueryBuilder<CardStudyRecordPO, int?, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<CardStudyRecordPO, int?, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<CardStudyRecordPO, String?, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<CardStudyRecordPO, String?, QQueryOperations>
      updateByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateBy');
    });
  }

  QueryBuilder<CardStudyRecordPO, int?, QQueryOperations> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateTime');
    });
  }

  QueryBuilder<CardStudyRecordPO, String?, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
