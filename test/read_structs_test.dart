import 'dart:io';

import 'package:ydart/lib0/byte_input_stream.dart';
import 'package:ydart/lib0/constans.dart';
import 'package:ydart/structs/abstract_struct.dart';
import 'package:ydart/structs/content_string.dart';
import 'package:ydart/structs/gc.dart';
import 'package:ydart/structs/item.dart';
import 'package:ydart/utils/encoding_utils.dart';
import 'package:ydart/utils/id.dart';
import 'package:ydart/utils/update_decoder_v2.dart';

void main() {
  var path = "./local/user-1/notes/57442830-e482-11ee-9c47-af0da659c832.wnote";
  var file = File(path);
  var bytes = file.readAsBytesSync();
  var decoder = UpdateDecoderV2(ByteArrayInputStream(bytes));

  var clientRefs = <int, List<AbstractStruct>>{};
  var numOfStateUpdates = decoder.reader.readVarUint();
  for (var i = 0; i < numOfStateUpdates; i++) {
    var numberOfStructs = decoder.reader.readVarUint();
    assert(numberOfStructs >= 0);
    var refs = <AbstractStruct>[];
    var client = decoder.readClient();
    var clock = decoder.reader.readVarUint();
    clientRefs[client] = refs;
    for (var j = 0; j < numberOfStructs; j++) {
      var info = decoder.readInfo();
      if ((Bits.bits5 & info) != 0) {
        var leftOrigin =
            (info & Bit.bit8) == Bit.bit8 ? decoder.readLeftId() : null;
        var rightOrigin =
            (info & Bit.bit7) == Bit.bit7 ? decoder.readRightId() : null;
        var cantCopyParentInfo = (info & (Bit.bit7 | Bit.bit8)) == 0;
        var hasParentYKey =
            cantCopyParentInfo ? decoder.readParentInfo() : false;
        var parentYKey =
            cantCopyParentInfo && hasParentYKey ? decoder.readString() : null;
        var item = Item.create(
          ID.create(client, clock),
          null,
          leftOrigin,
          null,
          rightOrigin,
          cantCopyParentInfo && !hasParentYKey
              ? decoder.readLeftId()
              : (parentYKey != null ? null : null),
          cantCopyParentInfo && (info & Bit.bit6) == Bit.bit6
              ? decoder.readString()
              : null,
          EncodingUtils.readItemContent(decoder, info),
        );
        var content = item.content;
        if (content is ContentString) {
          print(content.content);
        }
        refs.add(item);
        clock += item.length;
      } else {
        var length = decoder.readLength();
        refs.add(GC.create(ID.create(client, clock), length));
        clock += length;
      }
    }
  }
  var gcCount = 0;
  clientRefs.forEach((key, value) {
    gcCount += value
        .whereType<GC>()
        .map((e) => e.length)
        .reduce((value, element) => value + element);
  });
  print('gc count:${gcCount}');
}
