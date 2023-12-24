///
//  Generated code. Do not modify.
//  source: note.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class NoteElement_Row extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'NoteElement.Row', createEmptyInstance: create)
    ..pc<NoteElement>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'items', $pb.PbFieldType.PM, subBuilder: NoteElement.create)
    ..hasRequiredFields = false
  ;

  NoteElement_Row._() : super();
  factory NoteElement_Row({
    $core.Iterable<NoteElement>? items,
  }) {
    final _result = create();
    if (items != null) {
      _result.items.addAll(items);
    }
    return _result;
  }
  factory NoteElement_Row.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NoteElement_Row.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NoteElement_Row clone() => NoteElement_Row()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NoteElement_Row copyWith(void Function(NoteElement_Row) updates) => super.copyWith((message) => updates(message as NoteElement_Row)) as NoteElement_Row; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NoteElement_Row create() => NoteElement_Row._();
  NoteElement_Row createEmptyInstance() => create();
  static $pb.PbList<NoteElement_Row> createRepeated() => $pb.PbList<NoteElement_Row>();
  @$core.pragma('dart2js:noInline')
  static NoteElement_Row getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NoteElement_Row>(create);
  static NoteElement_Row? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<NoteElement> get items => $_getList(0);
}

class NoteElement extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'NoteElement', createEmptyInstance: create)
    ..pc<NoteElement>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'children', $pb.PbFieldType.PM, subBuilder: NoteElement.create)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type')
    ..aOB(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'newline')
    ..a<$core.int>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'level', $pb.PbFieldType.O3)
    ..a<$core.int>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'indent', $pb.PbFieldType.O3)
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'url')
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'alignment')
    ..aOS(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'text')
    ..a<$core.int>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'color', $pb.PbFieldType.O3)
    ..a<$core.int>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'background', $pb.PbFieldType.O3)
    ..aOB(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'bold')
    ..aOB(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'italic')
    ..a<$core.double>(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fontSize', $pb.PbFieldType.OD, protoName: 'fontSize')
    ..aOB(14, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'checked')
    ..aOS(15, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'itemType', protoName: 'itemType')
    ..aOB(16, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'underline')
    ..aOB(17, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'lineThrough', protoName: 'lineThrough')
    ..aOS(18, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'code')
    ..aOS(19, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'language')
    ..aOS(20, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aOS(21, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'file')
    ..a<$core.int>(22, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(23, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'height', $pb.PbFieldType.O3)
    ..m<$core.int, $core.String>(24, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'alignments', entryClassName: 'NoteElement.AlignmentsEntry', keyFieldType: $pb.PbFieldType.O3, valueFieldType: $pb.PbFieldType.OS)
    ..pc<NoteElement_Row>(26, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'rows', $pb.PbFieldType.PM, subBuilder: NoteElement_Row.create)
    ..hasRequiredFields = false
  ;

  NoteElement._() : super();
  factory NoteElement({
    $core.Iterable<NoteElement>? children,
    $core.String? type,
    $core.bool? newline,
    $core.int? level,
    $core.int? indent,
    $core.String? url,
    $core.String? alignment,
    $core.String? text,
    $core.int? color,
    $core.int? background,
    $core.bool? bold,
    $core.bool? italic,
    $core.double? fontSize,
    $core.bool? checked,
    $core.String? itemType,
    $core.bool? underline,
    $core.bool? lineThrough,
    $core.String? code,
    $core.String? language,
    $core.String? id,
    $core.String? file,
    $core.int? width,
    $core.int? height,
    $core.Map<$core.int, $core.String>? alignments,
    $core.Iterable<NoteElement_Row>? rows,
  }) {
    final _result = create();
    if (children != null) {
      _result.children.addAll(children);
    }
    if (type != null) {
      _result.type = type;
    }
    if (newline != null) {
      _result.newline = newline;
    }
    if (level != null) {
      _result.level = level;
    }
    if (indent != null) {
      _result.indent = indent;
    }
    if (url != null) {
      _result.url = url;
    }
    if (alignment != null) {
      _result.alignment = alignment;
    }
    if (text != null) {
      _result.text = text;
    }
    if (color != null) {
      _result.color = color;
    }
    if (background != null) {
      _result.background = background;
    }
    if (bold != null) {
      _result.bold = bold;
    }
    if (italic != null) {
      _result.italic = italic;
    }
    if (fontSize != null) {
      _result.fontSize = fontSize;
    }
    if (checked != null) {
      _result.checked = checked;
    }
    if (itemType != null) {
      _result.itemType = itemType;
    }
    if (underline != null) {
      _result.underline = underline;
    }
    if (lineThrough != null) {
      _result.lineThrough = lineThrough;
    }
    if (code != null) {
      _result.code = code;
    }
    if (language != null) {
      _result.language = language;
    }
    if (id != null) {
      _result.id = id;
    }
    if (file != null) {
      _result.file = file;
    }
    if (width != null) {
      _result.width = width;
    }
    if (height != null) {
      _result.height = height;
    }
    if (alignments != null) {
      _result.alignments.addAll(alignments);
    }
    if (rows != null) {
      _result.rows.addAll(rows);
    }
    return _result;
  }
  factory NoteElement.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NoteElement.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NoteElement clone() => NoteElement()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NoteElement copyWith(void Function(NoteElement) updates) => super.copyWith((message) => updates(message as NoteElement)) as NoteElement; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NoteElement create() => NoteElement._();
  NoteElement createEmptyInstance() => create();
  static $pb.PbList<NoteElement> createRepeated() => $pb.PbList<NoteElement>();
  @$core.pragma('dart2js:noInline')
  static NoteElement getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NoteElement>(create);
  static NoteElement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<NoteElement> get children => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get newline => $_getBF(2);
  @$pb.TagNumber(3)
  set newline($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNewline() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewline() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get level => $_getIZ(3);
  @$pb.TagNumber(4)
  set level($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLevel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLevel() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get indent => $_getIZ(4);
  @$pb.TagNumber(5)
  set indent($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIndent() => $_has(4);
  @$pb.TagNumber(5)
  void clearIndent() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get url => $_getSZ(5);
  @$pb.TagNumber(6)
  set url($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearUrl() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get alignment => $_getSZ(6);
  @$pb.TagNumber(7)
  set alignment($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAlignment() => $_has(6);
  @$pb.TagNumber(7)
  void clearAlignment() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get text => $_getSZ(7);
  @$pb.TagNumber(8)
  set text($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasText() => $_has(7);
  @$pb.TagNumber(8)
  void clearText() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get color => $_getIZ(8);
  @$pb.TagNumber(9)
  set color($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasColor() => $_has(8);
  @$pb.TagNumber(9)
  void clearColor() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get background => $_getIZ(9);
  @$pb.TagNumber(10)
  set background($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasBackground() => $_has(9);
  @$pb.TagNumber(10)
  void clearBackground() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get bold => $_getBF(10);
  @$pb.TagNumber(11)
  set bold($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasBold() => $_has(10);
  @$pb.TagNumber(11)
  void clearBold() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get italic => $_getBF(11);
  @$pb.TagNumber(12)
  set italic($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasItalic() => $_has(11);
  @$pb.TagNumber(12)
  void clearItalic() => clearField(12);

  @$pb.TagNumber(13)
  $core.double get fontSize => $_getN(12);
  @$pb.TagNumber(13)
  set fontSize($core.double v) { $_setDouble(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasFontSize() => $_has(12);
  @$pb.TagNumber(13)
  void clearFontSize() => clearField(13);

  @$pb.TagNumber(14)
  $core.bool get checked => $_getBF(13);
  @$pb.TagNumber(14)
  set checked($core.bool v) { $_setBool(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasChecked() => $_has(13);
  @$pb.TagNumber(14)
  void clearChecked() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get itemType => $_getSZ(14);
  @$pb.TagNumber(15)
  set itemType($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasItemType() => $_has(14);
  @$pb.TagNumber(15)
  void clearItemType() => clearField(15);

  @$pb.TagNumber(16)
  $core.bool get underline => $_getBF(15);
  @$pb.TagNumber(16)
  set underline($core.bool v) { $_setBool(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasUnderline() => $_has(15);
  @$pb.TagNumber(16)
  void clearUnderline() => clearField(16);

  @$pb.TagNumber(17)
  $core.bool get lineThrough => $_getBF(16);
  @$pb.TagNumber(17)
  set lineThrough($core.bool v) { $_setBool(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasLineThrough() => $_has(16);
  @$pb.TagNumber(17)
  void clearLineThrough() => clearField(17);

  @$pb.TagNumber(18)
  $core.String get code => $_getSZ(17);
  @$pb.TagNumber(18)
  set code($core.String v) { $_setString(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasCode() => $_has(17);
  @$pb.TagNumber(18)
  void clearCode() => clearField(18);

  @$pb.TagNumber(19)
  $core.String get language => $_getSZ(18);
  @$pb.TagNumber(19)
  set language($core.String v) { $_setString(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasLanguage() => $_has(18);
  @$pb.TagNumber(19)
  void clearLanguage() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get id => $_getSZ(19);
  @$pb.TagNumber(20)
  set id($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasId() => $_has(19);
  @$pb.TagNumber(20)
  void clearId() => clearField(20);

  @$pb.TagNumber(21)
  $core.String get file => $_getSZ(20);
  @$pb.TagNumber(21)
  set file($core.String v) { $_setString(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasFile() => $_has(20);
  @$pb.TagNumber(21)
  void clearFile() => clearField(21);

  @$pb.TagNumber(22)
  $core.int get width => $_getIZ(21);
  @$pb.TagNumber(22)
  set width($core.int v) { $_setSignedInt32(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasWidth() => $_has(21);
  @$pb.TagNumber(22)
  void clearWidth() => clearField(22);

  @$pb.TagNumber(23)
  $core.int get height => $_getIZ(22);
  @$pb.TagNumber(23)
  set height($core.int v) { $_setSignedInt32(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasHeight() => $_has(22);
  @$pb.TagNumber(23)
  void clearHeight() => clearField(23);

  @$pb.TagNumber(24)
  $core.Map<$core.int, $core.String> get alignments => $_getMap(23);

  @$pb.TagNumber(26)
  $core.List<NoteElement_Row> get rows => $_getList(24);
}

class NoteDom extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'NoteDom', createEmptyInstance: create)
    ..pc<NoteElement>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'elements', $pb.PbFieldType.PM, subBuilder: NoteElement.create)
    ..hasRequiredFields = false
  ;

  NoteDom._() : super();
  factory NoteDom({
    $core.Iterable<NoteElement>? elements,
  }) {
    final _result = create();
    if (elements != null) {
      _result.elements.addAll(elements);
    }
    return _result;
  }
  factory NoteDom.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NoteDom.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NoteDom clone() => NoteDom()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NoteDom copyWith(void Function(NoteDom) updates) => super.copyWith((message) => updates(message as NoteDom)) as NoteDom; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NoteDom create() => NoteDom._();
  NoteDom createEmptyInstance() => create();
  static $pb.PbList<NoteDom> createRepeated() => $pb.PbList<NoteDom>();
  @$core.pragma('dart2js:noInline')
  static NoteDom getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NoteDom>(create);
  static NoteDom? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<NoteElement> get elements => $_getList(0);
}

