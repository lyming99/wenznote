// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doc_file.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDocFileBytesCollection on Isar {
  IsarCollection<DocFileBytes> get docFileBytes => this.collection();
}

const DocFileBytesSchema = CollectionSchema(
  name: r'DocFileBytes',
  id: 4944988256159307945,
  properties: {
    r'contents': PropertySchema(
      id: 0,
      name: r'contents',
      type: IsarType.byteList,
    ),
    r'filename': PropertySchema(
      id: 1,
      name: r'filename',
      type: IsarType.string,
    ),
    r'saveInDir': PropertySchema(
      id: 2,
      name: r'saveInDir',
      type: IsarType.bool,
    )
  },
  estimateSize: _docFileBytesEstimateSize,
  serialize: _docFileBytesSerialize,
  deserialize: _docFileBytesDeserialize,
  deserializeProp: _docFileBytesDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _docFileBytesGetId,
  getLinks: _docFileBytesGetLinks,
  attach: _docFileBytesAttach,
  version: '3.1.0+1',
);

int _docFileBytesEstimateSize(
  DocFileBytes object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.contents;
    if (value != null) {
      bytesCount += 3 + value.length;
    }
  }
  {
    final value = object.filename;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _docFileBytesSerialize(
  DocFileBytes object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByteList(offsets[0], object.contents);
  writer.writeString(offsets[1], object.filename);
  writer.writeBool(offsets[2], object.saveInDir);
}

DocFileBytes _docFileBytesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DocFileBytes(
    contents: reader.readByteList(offsets[0]),
    filename: reader.readStringOrNull(offsets[1]),
    id: id,
    saveInDir: reader.readBoolOrNull(offsets[2]),
  );
  return object;
}

P _docFileBytesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readByteList(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _docFileBytesGetId(DocFileBytes object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _docFileBytesGetLinks(DocFileBytes object) {
  return [];
}

void _docFileBytesAttach(
    IsarCollection<dynamic> col, Id id, DocFileBytes object) {
  object.id = id;
}

extension DocFileBytesQueryWhereSort
    on QueryBuilder<DocFileBytes, DocFileBytes, QWhere> {
  QueryBuilder<DocFileBytes, DocFileBytes, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DocFileBytesQueryWhere
    on QueryBuilder<DocFileBytes, DocFileBytes, QWhereClause> {
  QueryBuilder<DocFileBytes, DocFileBytes, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterWhereClause> idBetween(
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

extension DocFileBytesQueryFilter
    on QueryBuilder<DocFileBytes, DocFileBytes, QFilterCondition> {
  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contents',
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contents',
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contents',
        value: value,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contents',
        value: value,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contents',
        value: value,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contents',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contents',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contents',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contents',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contents',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contents',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      contentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contents',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'filename',
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'filename',
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filename',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filename',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filename',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filename',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filename',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filename',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filename',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filename',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filename',
        value: '',
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      filenameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filename',
        value: '',
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      saveInDirIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'saveInDir',
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      saveInDirIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'saveInDir',
      ));
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterFilterCondition>
      saveInDirEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveInDir',
        value: value,
      ));
    });
  }
}

extension DocFileBytesQueryObject
    on QueryBuilder<DocFileBytes, DocFileBytes, QFilterCondition> {}

extension DocFileBytesQueryLinks
    on QueryBuilder<DocFileBytes, DocFileBytes, QFilterCondition> {}

extension DocFileBytesQuerySortBy
    on QueryBuilder<DocFileBytes, DocFileBytes, QSortBy> {
  QueryBuilder<DocFileBytes, DocFileBytes, QAfterSortBy> sortByFilename() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filename', Sort.asc);
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterSortBy> sortByFilenameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filename', Sort.desc);
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterSortBy> sortBySaveInDir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveInDir', Sort.asc);
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterSortBy> sortBySaveInDirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveInDir', Sort.desc);
    });
  }
}

extension DocFileBytesQuerySortThenBy
    on QueryBuilder<DocFileBytes, DocFileBytes, QSortThenBy> {
  QueryBuilder<DocFileBytes, DocFileBytes, QAfterSortBy> thenByFilename() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filename', Sort.asc);
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterSortBy> thenByFilenameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filename', Sort.desc);
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterSortBy> thenBySaveInDir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveInDir', Sort.asc);
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QAfterSortBy> thenBySaveInDirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveInDir', Sort.desc);
    });
  }
}

extension DocFileBytesQueryWhereDistinct
    on QueryBuilder<DocFileBytes, DocFileBytes, QDistinct> {
  QueryBuilder<DocFileBytes, DocFileBytes, QDistinct> distinctByContents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contents');
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QDistinct> distinctByFilename(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filename', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocFileBytes, DocFileBytes, QDistinct> distinctBySaveInDir() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveInDir');
    });
  }
}

extension DocFileBytesQueryProperty
    on QueryBuilder<DocFileBytes, DocFileBytes, QQueryProperty> {
  QueryBuilder<DocFileBytes, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DocFileBytes, List<int>?, QQueryOperations> contentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contents');
    });
  }

  QueryBuilder<DocFileBytes, String?, QQueryOperations> filenameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filename');
    });
  }

  QueryBuilder<DocFileBytes, bool?, QQueryOperations> saveInDirProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveInDir');
    });
  }
}
