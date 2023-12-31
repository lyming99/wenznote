//
//  Generated code. Do not modify.
//  source: p2p_packet.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use p2pPacketDescriptor instead')
const P2pPacket$json = {
  '1': 'P2pPacket',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'clientId', '3': 2, '4': 1, '5': 3, '10': 'clientId'},
    {'1': 'dataIdList', '3': 3, '4': 3, '5': 9, '10': 'dataIdList'},
    {'1': 'clientTime', '3': 4, '4': 1, '5': 3, '10': 'clientTime'},
    {'1': 'content', '3': 100, '4': 1, '5': 12, '10': 'content'},
  ],
};

/// Descriptor for `P2pPacket`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List p2pPacketDescriptor = $convert.base64Decode(
    'CglQMnBQYWNrZXQSEgoEdHlwZRgBIAEoBVIEdHlwZRIaCghjbGllbnRJZBgCIAEoA1IIY2xpZW'
    '50SWQSHgoKZGF0YUlkTGlzdBgDIAMoCVIKZGF0YUlkTGlzdBIeCgpjbGllbnRUaW1lGAQgASgD'
    'UgpjbGllbnRUaW1lEhgKB2NvbnRlbnQYZCABKAxSB2NvbnRlbnQ=');

