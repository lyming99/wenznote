///
//  Generated code. Do not modify.
//  source: note.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use noteElementDescriptor instead')
const NoteElement$json = const {
  '1': 'NoteElement',
  '2': const [
    const {'1': 'children', '3': 1, '4': 3, '5': 11, '6': '.NoteElement', '10': 'children'},
    const {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'newline', '3': 3, '4': 1, '5': 8, '10': 'newline'},
    const {'1': 'level', '3': 4, '4': 1, '5': 5, '10': 'level'},
    const {'1': 'indent', '3': 5, '4': 1, '5': 5, '10': 'indent'},
    const {'1': 'url', '3': 6, '4': 1, '5': 9, '10': 'url'},
    const {'1': 'alignment', '3': 7, '4': 1, '5': 9, '10': 'alignment'},
    const {'1': 'text', '3': 8, '4': 1, '5': 9, '10': 'text'},
    const {'1': 'color', '3': 9, '4': 1, '5': 5, '10': 'color'},
    const {'1': 'background', '3': 10, '4': 1, '5': 5, '10': 'background'},
    const {'1': 'bold', '3': 11, '4': 1, '5': 8, '10': 'bold'},
    const {'1': 'italic', '3': 12, '4': 1, '5': 8, '10': 'italic'},
    const {'1': 'fontSize', '3': 13, '4': 1, '5': 1, '10': 'fontSize'},
    const {'1': 'checked', '3': 14, '4': 1, '5': 8, '10': 'checked'},
    const {'1': 'itemType', '3': 15, '4': 1, '5': 9, '10': 'itemType'},
    const {'1': 'underline', '3': 16, '4': 1, '5': 8, '10': 'underline'},
    const {'1': 'lineThrough', '3': 17, '4': 1, '5': 8, '10': 'lineThrough'},
    const {'1': 'code', '3': 18, '4': 1, '5': 9, '10': 'code'},
    const {'1': 'language', '3': 19, '4': 1, '5': 9, '10': 'language'},
    const {'1': 'id', '3': 20, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'file', '3': 21, '4': 1, '5': 9, '10': 'file'},
    const {'1': 'width', '3': 22, '4': 1, '5': 5, '10': 'width'},
    const {'1': 'height', '3': 23, '4': 1, '5': 5, '10': 'height'},
    const {'1': 'alignments', '3': 24, '4': 3, '5': 11, '6': '.NoteElement.AlignmentsEntry', '10': 'alignments'},
    const {'1': 'rows', '3': 26, '4': 3, '5': 11, '6': '.NoteElement.Row', '10': 'rows'},
  ],
  '3': const [NoteElement_AlignmentsEntry$json, NoteElement_Row$json],
};

@$core.Deprecated('Use noteElementDescriptor instead')
const NoteElement_AlignmentsEntry$json = const {
  '1': 'AlignmentsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use noteElementDescriptor instead')
const NoteElement_Row$json = const {
  '1': 'Row',
  '2': const [
    const {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.NoteElement', '10': 'items'},
  ],
};

/// Descriptor for `NoteElement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteElementDescriptor = $convert.base64Decode('CgtOb3RlRWxlbWVudBIoCghjaGlsZHJlbhgBIAMoCzIMLk5vdGVFbGVtZW50UghjaGlsZHJlbhISCgR0eXBlGAIgASgJUgR0eXBlEhgKB25ld2xpbmUYAyABKAhSB25ld2xpbmUSFAoFbGV2ZWwYBCABKAVSBWxldmVsEhYKBmluZGVudBgFIAEoBVIGaW5kZW50EhAKA3VybBgGIAEoCVIDdXJsEhwKCWFsaWdubWVudBgHIAEoCVIJYWxpZ25tZW50EhIKBHRleHQYCCABKAlSBHRleHQSFAoFY29sb3IYCSABKAVSBWNvbG9yEh4KCmJhY2tncm91bmQYCiABKAVSCmJhY2tncm91bmQSEgoEYm9sZBgLIAEoCFIEYm9sZBIWCgZpdGFsaWMYDCABKAhSBml0YWxpYxIaCghmb250U2l6ZRgNIAEoAVIIZm9udFNpemUSGAoHY2hlY2tlZBgOIAEoCFIHY2hlY2tlZBIaCghpdGVtVHlwZRgPIAEoCVIIaXRlbVR5cGUSHAoJdW5kZXJsaW5lGBAgASgIUgl1bmRlcmxpbmUSIAoLbGluZVRocm91Z2gYESABKAhSC2xpbmVUaHJvdWdoEhIKBGNvZGUYEiABKAlSBGNvZGUSGgoIbGFuZ3VhZ2UYEyABKAlSCGxhbmd1YWdlEg4KAmlkGBQgASgJUgJpZBISCgRmaWxlGBUgASgJUgRmaWxlEhQKBXdpZHRoGBYgASgFUgV3aWR0aBIWCgZoZWlnaHQYFyABKAVSBmhlaWdodBI8CgphbGlnbm1lbnRzGBggAygLMhwuTm90ZUVsZW1lbnQuQWxpZ25tZW50c0VudHJ5UgphbGlnbm1lbnRzEiQKBHJvd3MYGiADKAsyEC5Ob3RlRWxlbWVudC5Sb3dSBHJvd3MaPQoPQWxpZ25tZW50c0VudHJ5EhAKA2tleRgBIAEoBVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAEaKQoDUm93EiIKBWl0ZW1zGAEgAygLMgwuTm90ZUVsZW1lbnRSBWl0ZW1z');
@$core.Deprecated('Use noteDomDescriptor instead')
const NoteDom$json = const {
  '1': 'NoteDom',
  '2': const [
    const {'1': 'elements', '3': 1, '4': 3, '5': 11, '6': '.NoteElement', '10': 'elements'},
  ],
};

/// Descriptor for `NoteDom`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteDomDescriptor = $convert.base64Decode('CgdOb3RlRG9tEigKCGVsZW1lbnRzGAEgAygLMgwuTm90ZUVsZW1lbnRSCGVsZW1lbnRz');
