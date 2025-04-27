import 'dart:convert';

import 'package:flutter/material.dart';

class _CachedImage {
  final ImageProvider image;
  final String url;

  _CachedImage({required this.image, required this.url});
}

class ImageCacheProvider {
  // Tres mapas para almacenar las imágenes por tipo (usuarios, vehículos, actividades)
  final Map<String, _CachedImage> _userCache = {};
  final Map<String, _CachedImage> _vehicleCache = {};
  final Map<String, _CachedImage> _activityCache = {};

  // Función genérica para obtener imágenes de caché
  ImageProvider getImage(String type, String id, String url, {bool isNetwork = false}) {
    Map<String, _CachedImage> cache;

    switch (type) {
      case 'user':
        cache = _userCache;
        break;
      case 'vehicle':
        cache = _vehicleCache;
        break;
      case 'activity':
        cache = _activityCache;
        break;
      default:
        throw ArgumentError('Tipo de imagen desconocido: $type');
    }

    if (cache.containsKey(id)) {
      final cachedImage = cache[id]!;

      if (cachedImage.url == url) {
        print('Imagen ya está en caché: ${url.characters.take(50).toString()}');
        return cachedImage.image;
      }
    }

    ImageProvider image = isNetwork ? NetworkImage(url) : MemoryImage(base64Decode(url));

    cache[id] = _CachedImage(image: image, url: url);
    print('Imagen añadida a caché: ${url.characters.take(50).toString()}');

    if (type == "activity" &&  cache.length > 20) {
      cache.remove(cache.keys.first);
    }

    return image;
  }
}
