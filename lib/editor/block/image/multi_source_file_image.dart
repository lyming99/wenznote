import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef MultiSourceImageReader = Future<Uint8List> Function(String imageId);

class MultiSourceFileImage extends ImageProvider<MultiSourceFileImage> {
  /// Creates an object that decodes a [File] as an image.
  ///
  /// The arguments must not be null.
  MultiSourceFileImage(
      {required this.imageId, required this.reader, this.scale = 1.0});

  MultiSourceImageReader reader;

  /// The file to decode into an image.
  final String imageId;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<MultiSourceFileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MultiSourceFileImage>(this);
  }

  @override
  ImageStreamCompleter load(MultiSourceFileImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, null, decode),
      scale: key.scale,
      debugLabel: key.imageId,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('imageId: ${imageId}'),
      ],
    );
  }

  @override
  ImageStreamCompleter loadBuffer(
      MultiSourceFileImage key, DecoderBufferCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode, null),
      scale: key.scale,
      debugLabel: key.imageId,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('image id: ${imageId}'),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(MultiSourceFileImage key,
      DecoderBufferCallback? decode, DecoderCallback? decodeDeprecated) async {
    assert(key == this);

    final Uint8List bytes = await reader.call(key.imageId);
    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError(
          'image: $imageId is empty and cannot be loaded as an image.');
    }

    if (decode != null) {
      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    }
    return decodeDeprecated!(bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MultiSourceFileImage &&
        other.imageId == imageId &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(imageId, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'MultiSourceImageFile')}("${imageId}", scale: $scale)';
}
