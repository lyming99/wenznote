// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_task_po.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUploadTaskPOCollection on Isar {
  IsarCollection<UploadTaskPO> get uploadTaskPOs => this.collection();
}

const UploadTaskPOSchema = CollectionSchema(
  name: r'UploadTaskPO',
  id: 6230953505184036661,
  properties: {
    r'dataId': PropertySchema(
      id: 0,
      name: r'dataId',
      type: IsarType.string,
    ),
    r'isDone': PropertySchema(
      id: 1,
      name: r'isDone',
      type: IsarType.bool,
    ),
    r'planTime': PropertySchema(
      id: 2,
      name: r'planTime',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _uploadTaskPOEstimateSize,
  serialize: _uploadTaskPOSerialize,
  deserialize: _uploadTaskPODeserialize,
  deserializeProp: _uploadTaskPODeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _uploadTaskPOGetId,
  getLinks: _uploadTaskPOGetLinks,
  attach: _uploadTaskPOAttach,
  version: '3.1.0+1',
);

int _uploadTaskPOEstimateSize(
  UploadTaskPO object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.dataId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.type;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _uploadTaskPOSerialize(
  UploadTaskPO object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.dataId);
  writer.writeBool(offsets[1], object.isDone);
  writer.writeLong(offsets[2], object.planTime);
  writer.writeString(offsets[3], object.type);
}

UploadTaskPO _uploadTaskPODeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UploadTaskPO(
    dataId: reader.readStringOrNull(offsets[0]),
    id: id,
    planTime: reader.readLongOrNull(offsets[2]),
    type: reader.readStringOrNull(offsets[3]),
  );
  object.isDone = reader.readBoolOrNull(offsets[1]);
  return object;
}

P _uploadTaskPODeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _uploadTaskPOGetId(UploadTaskPO object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _uploadTaskPOGetLinks(UploadTaskPO object) {
  return [];
}

void _uploadTaskPOAttach(
    IsarCollection<dynamic> col, Id id, UploadTaskPO object) {
  object.id = id;
}

extension UploadTaskPOQueryWhereSort
    on QueryBuilder<UploadTaskPO, UploadTaskPO, QWhere> {
  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UploadTaskPOQueryWhere
    on QueryBuilder<UploadTaskPO, UploadTaskPO, QWhereClause> {
  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterWhereClause> idBetween(
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

extension UploadTaskPOQueryFilter
    on QueryBuilder<UploadTaskPO, UploadTaskPO, QFilterCondition> {
  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      dataIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dataId',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      dataIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dataId',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> dataIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      dataIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      dataIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> dataIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      dataIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dataId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      dataIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dataId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      dataIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> dataIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      dataIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataId',
        value: '',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      dataIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataId',
        value: '',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      isDoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isDone',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      isDoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isDone',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> isDoneEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDone',
        value: value,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      planTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'planTime',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      planTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'planTime',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      planTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      planTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'planTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      planTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'planTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      planTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'planTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> typeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'type',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      typeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'type',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> typeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      typeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> typeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> typeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension UploadTaskPOQueryObject
    on QueryBuilder<UploadTaskPO, UploadTaskPO, QFilterCondition> {}

extension UploadTaskPOQueryLinks
    on QueryBuilder<UploadTaskPO, UploadTaskPO, QFilterCondition> {}

extension UploadTaskPOQuerySortBy
    on QueryBuilder<UploadTaskPO, UploadTaskPO, QSortBy> {
  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> sortByDataId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataId', Sort.asc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> sortByDataIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataId', Sort.desc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> sortByIsDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDone', Sort.asc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> sortByIsDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDone', Sort.desc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> sortByPlanTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planTime', Sort.asc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> sortByPlanTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planTime', Sort.desc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension UploadTaskPOQuerySortThenBy
    on QueryBuilder<UploadTaskPO, UploadTaskPO, QSortThenBy> {
  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> thenByDataId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataId', Sort.asc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> thenByDataIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataId', Sort.desc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> thenByIsDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDone', Sort.asc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> thenByIsDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDone', Sort.desc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> thenByPlanTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planTime', Sort.asc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> thenByPlanTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planTime', Sort.desc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension UploadTaskPOQueryWhereDistinct
    on QueryBuilder<UploadTaskPO, UploadTaskPO, QDistinct> {
  QueryBuilder<UploadTaskPO, UploadTaskPO, QDistinct> distinctByDataId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QDistinct> distinctByIsDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDone');
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QDistinct> distinctByPlanTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planTime');
    });
  }

  QueryBuilder<UploadTaskPO, UploadTaskPO, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension UploadTaskPOQueryProperty
    on QueryBuilder<UploadTaskPO, UploadTaskPO, QQueryProperty> {
  QueryBuilder<UploadTaskPO, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UploadTaskPO, String?, QQueryOperations> dataIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataId');
    });
  }

  QueryBuilder<UploadTaskPO, bool?, QQueryOperations> isDoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDone');
    });
  }

  QueryBuilder<UploadTaskPO, int?, QQueryOperations> planTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planTime');
    });
  }

  QueryBuilder<UploadTaskPO, String?, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
