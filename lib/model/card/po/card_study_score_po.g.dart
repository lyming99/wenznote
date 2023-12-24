// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_study_score_po.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCardStudyScorePOCollection on Isar {
  IsarCollection<CardStudyScorePO> get cardStudyScorePOs => this.collection();
}

const CardStudyScorePOSchema = CollectionSchema(
  name: r'CardStudyScorePO',
  id: 5894514972350770546,
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
    r'score': PropertySchema(
      id: 6,
      name: r'score',
      type: IsarType.string,
    ),
    r'scoreInfo': PropertySchema(
      id: 7,
      name: r'scoreInfo',
      type: IsarType.string,
    ),
    r'startTime': PropertySchema(
      id: 8,
      name: r'startTime',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(
      id: 9,
      name: r'uid',
      type: IsarType.string,
    ),
    r'updateBy': PropertySchema(
      id: 10,
      name: r'updateBy',
      type: IsarType.string,
    ),
    r'updateTime': PropertySchema(
      id: 11,
      name: r'updateTime',
      type: IsarType.long,
    ),
    r'uuid': PropertySchema(
      id: 12,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _cardStudyScorePOEstimateSize,
  serialize: _cardStudyScorePOSerialize,
  deserialize: _cardStudyScorePODeserialize,
  deserializeProp: _cardStudyScorePODeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _cardStudyScorePOGetId,
  getLinks: _cardStudyScorePOGetLinks,
  attach: _cardStudyScorePOAttach,
  version: '3.1.0+1',
);

int _cardStudyScorePOEstimateSize(
  CardStudyScorePO object,
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
    final value = object.score;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.scoreInfo;
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

void _cardStudyScorePOSerialize(
  CardStudyScorePO object,
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
  writer.writeString(offsets[6], object.score);
  writer.writeString(offsets[7], object.scoreInfo);
  writer.writeLong(offsets[8], object.startTime);
  writer.writeString(offsets[9], object.uid);
  writer.writeString(offsets[10], object.updateBy);
  writer.writeLong(offsets[11], object.updateTime);
  writer.writeString(offsets[12], object.uuid);
}

CardStudyScorePO _cardStudyScorePODeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CardStudyScorePO(
    cardId: reader.readStringOrNull(offsets[0]),
    cardSetId: reader.readStringOrNull(offsets[1]),
    createBy: reader.readStringOrNull(offsets[2]),
    createTime: reader.readLongOrNull(offsets[3]),
    did: reader.readStringOrNull(offsets[4]),
    endTime: reader.readLongOrNull(offsets[5]),
    id: id,
    score: reader.readStringOrNull(offsets[6]),
    scoreInfo: reader.readStringOrNull(offsets[7]),
    startTime: reader.readLongOrNull(offsets[8]),
    uid: reader.readStringOrNull(offsets[9]),
    updateBy: reader.readStringOrNull(offsets[10]),
    updateTime: reader.readLongOrNull(offsets[11]),
    uuid: reader.readStringOrNull(offsets[12]),
  );
  return object;
}

P _cardStudyScorePODeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cardStudyScorePOGetId(CardStudyScorePO object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cardStudyScorePOGetLinks(CardStudyScorePO object) {
  return [];
}

void _cardStudyScorePOAttach(
    IsarCollection<dynamic> col, Id id, CardStudyScorePO object) {
  object.id = id;
}

extension CardStudyScorePOQueryWhereSort
    on QueryBuilder<CardStudyScorePO, CardStudyScorePO, QWhere> {
  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CardStudyScorePOQueryWhere
    on QueryBuilder<CardStudyScorePO, CardStudyScorePO, QWhereClause> {
  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterWhereClause>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterWhereClause> idBetween(
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

extension CardStudyScorePOQueryFilter
    on QueryBuilder<CardStudyScorePO, CardStudyScorePO, QFilterCondition> {
  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cardId',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cardId',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardSetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cardSetId',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardSetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cardSetId',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardSetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardSetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardSetIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardSetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardSetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardSetId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      cardSetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardSetId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      createByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createBy',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      createByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createBy',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      createByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      createByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      createByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      createByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      createTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      createTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      createTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      didIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'did',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      didIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'did',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      didContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      didMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'did',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      didIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      didIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      endTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'score',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'score',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'score',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'score',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'score',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'score',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'score',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scoreInfo',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scoreInfo',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scoreInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scoreInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scoreInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scoreInfo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scoreInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scoreInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scoreInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scoreInfo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scoreInfo',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      scoreInfoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scoreInfo',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      startTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startTime',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      startTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startTime',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      startTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uid',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uid',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      updateByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updateBy',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      updateByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updateBy',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      updateByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'updateBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      updateByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'updateBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      updateByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      updateByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'updateBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      updateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      updateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      updateTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uuid',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uuid',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension CardStudyScorePOQueryObject
    on QueryBuilder<CardStudyScorePO, CardStudyScorePO, QFilterCondition> {}

extension CardStudyScorePOQueryLinks
    on QueryBuilder<CardStudyScorePO, CardStudyScorePO, QFilterCondition> {}

extension CardStudyScorePOQuerySortBy
    on QueryBuilder<CardStudyScorePO, CardStudyScorePO, QSortBy> {
  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByCardSetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByCardSetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByCreateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByCreateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy> sortByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy> sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByScoreInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreInfo', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByScoreInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreInfo', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByUpdateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByUpdateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension CardStudyScorePOQuerySortThenBy
    on QueryBuilder<CardStudyScorePO, CardStudyScorePO, QSortThenBy> {
  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByCardSetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByCardSetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByCreateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByCreateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy> thenByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy> thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByScoreInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreInfo', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByScoreInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreInfo', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByUpdateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByUpdateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension CardStudyScorePOQueryWhereDistinct
    on QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct> {
  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct> distinctByCardId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct>
      distinctByCardSetId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardSetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct>
      distinctByCreateBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct>
      distinctByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createTime');
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct> distinctByDid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'did', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct>
      distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct> distinctByScore(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct>
      distinctByScoreInfo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scoreInfo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct>
      distinctByUpdateBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct>
      distinctByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateTime');
    });
  }

  QueryBuilder<CardStudyScorePO, CardStudyScorePO, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension CardStudyScorePOQueryProperty
    on QueryBuilder<CardStudyScorePO, CardStudyScorePO, QQueryProperty> {
  QueryBuilder<CardStudyScorePO, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CardStudyScorePO, String?, QQueryOperations> cardIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardId');
    });
  }

  QueryBuilder<CardStudyScorePO, String?, QQueryOperations>
      cardSetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardSetId');
    });
  }

  QueryBuilder<CardStudyScorePO, String?, QQueryOperations> createByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createBy');
    });
  }

  QueryBuilder<CardStudyScorePO, int?, QQueryOperations> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createTime');
    });
  }

  QueryBuilder<CardStudyScorePO, String?, QQueryOperations> didProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'did');
    });
  }

  QueryBuilder<CardStudyScorePO, int?, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<CardStudyScorePO, String?, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<CardStudyScorePO, String?, QQueryOperations>
      scoreInfoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scoreInfo');
    });
  }

  QueryBuilder<CardStudyScorePO, int?, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<CardStudyScorePO, String?, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<CardStudyScorePO, String?, QQueryOperations> updateByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateBy');
    });
  }

  QueryBuilder<CardStudyScorePO, int?, QQueryOperations> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateTime');
    });
  }

  QueryBuilder<CardStudyScorePO, String?, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
