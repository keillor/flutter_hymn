import 'dart:io';

import 'package:flutter_hymn/models/cart.dart';
import 'package:flutter_hymn/models/hymn.dart';
import 'package:path_provider/path_provider.dart';

class FavoriteCart extends Cart {
  FavoriteCart._internal(super.cartName);

  static Future<FavoriteCart> create() async {
    final cart = FavoriteCart._internal('Favorites');
    await cart.loadFavorites();
    return cart;
  }

  Future<void> loadFavorites() async {
    final favorites = await getFavoriteHymns();
    hymns.clear();
    hymns.addAll(favorites);
    notifyListeners();
  }

  Future<bool> addFavoriteHymn(Hymn hymn) async {
    final success = await addFavorite(hymn.number);
    if (success && !hymns.any((h) => h.number == hymn.number)) {
      hymns.add(hymn);
      notifyListeners();
    }
    return success;
  }

  Future<bool> removeFavoriteHymn(int hymnNumber) async {
    final success = await removeFavorite(hymnNumber);
    if (success) {
      hymns.removeWhere((h) => h.number == hymnNumber);
      notifyListeners();
    }
    return success;
  }

  bool containsHymn(int hymnNumber) {
    return hymns.any((h) => h.number == hymnNumber);
  }
}

Future<String> _prepareDb() async {
  final docs = await getApplicationDocumentsDirectory();
  final dbFile = File('${docs.path}/hymns.db');

  return dbFile.path;
}