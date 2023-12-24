// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_study_queue_po.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCardStudyQueuePOCollection on Isar {
  IsarCollection<CardStudyQueuePO> get cardStudyQueuePOs => this.collection();
}

const CardStudyQueuePOSchema = CollectionSchema(
  name: r'CardStudyQueuePO',
  id: 3091882568795337676,
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
    r'hasStudy': PropertySchema(
      id: 5,
      name: r'hasStudy',
      type: IsarType.bool,
    ),
    r'orderIndex': PropertySchema(
      id: 6,
      name: r'orderIndex',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(
      id: 7,
      name: r'uid',
      type: IsarType.string,
    ),
    r'updateBy': PropertySchema(
      id: 8,
      name: r'updateBy',
      type: IsarType.string,
    ),
    r'updateTime': PropertySchema(
      id: 9,
      name: r'updateTime',
      type: IsarType.long,
    ),
    r'uuid': PropertySchema(
      id: 10,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _cardStudyQueuePOEstimateSize,
  serialize: _cardStudyQueuePOSerialize,
  deserialize: _cardStudyQueuePODeserialize,
  deserializeProp: _cardStudyQueuePODeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _cardStudyQueuePOGetId,
  getLinks: _cardStudyQueuePOGetLinks,
  attach: _cardStudyQueuePOAttach,
  version: '3.1.0+1',
);

int _cardStudyQueuePOEstimateSize(
  CardStudyQueuePO object,
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

void _cardStudyQueuePOSerialize(
  CardStudyQueuePO object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cardId);
  writer.writeString(offsets[1], object.cardSetId);
  writer.writeString(offsets[2], object.createBy);
  writer.writeLong(offsets[3], object.createTime);
  writer.writeString(offsets[4], object.did);
  writer.writeBool(offsets[5], object.hasStudy);
  writer.writeLong(offsets[6], object.orderIndex);
  writer.writeString(offsets[7], object.uid);
  writer.writeString(offsets[8], object.updateBy);
  writer.writeLong(offsets[9], object.updateTime);
  writer.writeString(offsets[10], object.uuid);
}

CardStudyQueuePO _cardStudyQueuePODeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CardStudyQueuePO(
    cardId: reader.readStringOrNull(offsets[0]),
    cardSetId: reader.readStringOrNull(offsets[1]),
    createBy: reader.readStringOrNull(offsets[2]),
    createTime: reader.readLongOrNull(offsets[3]),
    did: reader.readStringOrNull(offsets[4]),
    hasStudy: reader.readBoolOrNull(offsets[5]),
    id: id,
    orderIndex: reader.readLongOrNull(offsets[6]),
    uid: reader.readStringOrNull(offsets[7]),
    updateBy: reader.readStringOrNull(offsets[8]),
    updateTime: reader.readLongOrNull(offsets[9]),
    uuid: reader.readStringOrNull(offsets[10]),
  );
  return object;
}

P _cardStudyQueuePODeserializeProp<P>(
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
      return (reader.readBoolOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cardStudyQueuePOGetId(CardStudyQueuePO object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cardStudyQueuePOGetLinks(CardStudyQueuePO object) {
  return [];
}

void _cardStudyQueuePOAttach(
    IsarCollection<dynamic> col, Id id, CardStudyQueuePO object) {
  object.id = id;
}

extension CardStudyQueuePOQueryWhereSort
    on QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QWhere> {
  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CardStudyQueuePOQueryWhere
    on QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QWhereClause> {
  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterWhereClause>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterWhereClause> idBetween(
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

extension CardStudyQueuePOQueryFilter
    on QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QFilterCondition> {
  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cardId',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cardId',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardSetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cardSetId',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardSetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cardSetId',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardSetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardSetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardSetIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardSetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardSetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardSetId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      cardSetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardSetId',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      createByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createBy',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      createByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createBy',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      createByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      createByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      createByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      createByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      createTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      createTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      createTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      didIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'did',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      didIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'did',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      didContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      didMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'did',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      didIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      didIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      hasStudyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hasStudy',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      hasStudyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hasStudy',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      hasStudyEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasStudy',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      orderIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'orderIndex',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      orderIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'orderIndex',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      orderIndexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      orderIndexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      orderIndexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      orderIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uid',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uid',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      updateByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updateBy',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      updateByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updateBy',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      updateByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'updateBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      updateByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'updateBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      updateByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      updateByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'updateBy',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      updateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      updateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      updateTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uuid',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uuid',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
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

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension CardStudyQueuePOQueryObject
    on QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QFilterCondition> {}

extension CardStudyQueuePOQueryLinks
    on QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QFilterCondition> {}

extension CardStudyQueuePOQuerySortBy
    on QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QSortBy> {
  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByCardSetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByCardSetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByCreateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByCreateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy> sortByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByHasStudy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasStudy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByHasStudyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasStudy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByUpdateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByUpdateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension CardStudyQueuePOQuerySortThenBy
    on QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QSortThenBy> {
  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByCardSetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByCardSetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardSetId', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByCreateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByCreateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy> thenByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByHasStudy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasStudy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByHasStudyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasStudy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByUpdateBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByUpdateByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateBy', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension CardStudyQueuePOQueryWhereDistinct
    on QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct> {
  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct> distinctByCardId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct>
      distinctByCardSetId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardSetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct>
      distinctByCreateBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct>
      distinctByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createTime');
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct> distinctByDid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'did', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct>
      distinctByHasStudy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasStudy');
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct>
      distinctByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderIndex');
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct>
      distinctByUpdateBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct>
      distinctByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateTime');
    });
  }

  QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension CardStudyQueuePOQueryProperty
    on QueryBuilder<CardStudyQueuePO, CardStudyQueuePO, QQueryProperty> {
  QueryBuilder<CardStudyQueuePO, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CardStudyQueuePO, String?, QQueryOperations> cardIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardId');
    });
  }

  QueryBuilder<CardStudyQueuePO, String?, QQueryOperations>
      cardSetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardSetId');
    });
  }

  QueryBuilder<CardStudyQueuePO, String?, QQueryOperations> createByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createBy');
    });
  }

  QueryBuilder<CardStudyQueuePO, int?, QQueryOperations> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createTime');
    });
  }

  QueryBuilder<CardStudyQueuePO, String?, QQueryOperations> didProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'did');
    });
  }

  QueryBuilder<CardStudyQueuePO, bool?, QQueryOperations> hasStudyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasStudy');
    });
  }

  QueryBuilder<CardStudyQueuePO, int?, QQueryOperations> orderIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderIndex');
    });
  }

  QueryBuilder<CardStudyQueuePO, String?, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<CardStudyQueuePO, String?, QQueryOperations> updateByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateBy');
    });
  }

  QueryBuilder<CardStudyQueuePO, int?, QQueryOperations> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateTime');
    });
  }

  QueryBuilder<CardStudyQueuePO, String?, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
