//
//  Generated code. Do not modify.
//  source: p2p_packet.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class P2pPacket extends $pb.GeneratedMessage {
  factory P2pPacket({
    $core.int? type,
    $fixnum.Int64? clientId,
    $core.Iterable<$core.String>? dataIdList,
    $fixnum.Int64? clientTime,
    $core.List<$core.int>? content,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (dataIdList != null) {
      $result.dataIdList.addAll(dataIdList);
    }
    if (clientTime != null) {
      $result.clientTime = clientTime;
    }
    if (content != null) {
      $result.content = content;
    }
    return $result;
  }
  P2pPacket._() : super();
  factory P2pPacket.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory P2pPacket.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'P2pPacket', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.O3)
    ..aInt64(2, _omitFieldNames ? '' : 'clientId', protoName: 'clientId')
    ..pPS(3, _omitFieldNames ? '' : 'dataIdList', protoName: 'dataIdList')
    ..aInt64(4, _omitFieldNames ? '' : 'clientTime', protoName: 'clientTime')
    ..a<$core.List<$core.int>>(100, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  P2pPacket clone() => P2pPacket()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  P2pPacket copyWith(void Function(P2pPacket) updates) => super.copyWith((message) => updates(message as P2pPacket)) as P2pPacket;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static P2pPacket create() => P2pPacket._();
  P2pPacket createEmptyInstance() => create();
  static $pb.PbList<P2pPacket> createRepeated() => $pb.PbList<P2pPacket>();
  @$core.pragma('dart2js:noInline')
  static P2pPacket getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<P2pPacket>(create);
  static P2pPacket? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get clientId => $_getI64(1);
  @$pb.TagNumber(2)
  set clientId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get dataIdList => $_getList(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get clientTime => $_getI64(3);
  @$pb.TagNumber(4)
  set clientTime($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasClientTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientTime() => clearField(4);

  @$pb.TagNumber(100)
  $core.List<$core.int> get content => $_getN(4);
  @$pb.TagNumber(100)
  set content($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(100)
  $core.bool hasContent() => $_has(4);
  @$pb.TagNumber(100)
  void clearContent() => clearField(100);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
