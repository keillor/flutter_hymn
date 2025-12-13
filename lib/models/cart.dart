import 'package:flutter_hymn/models/hymn.dart';
import 'package:flutter/foundation.dart';

class Cart extends ChangeNotifier {
  final String cartName;
  final List<Hymn> hymns;

  Cart(this.cartName) : hymns = [];

  void addToCart(Hymn hymn) {
    hymns.add(hymn);
    notifyListeners();
  }

  void removeAt(int index) {
    if (index >= 0 && index < hymns.length) {
      hymns.removeAt(index);
      notifyListeners();
    }
  }

  void move(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= hymns.length) return;
    if (newIndex < 0) newIndex = 0;
    if (newIndex > hymns.length) newIndex = hymns.length;
    final Hymn item = hymns.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex -= 1;
    hymns.insert(newIndex, item);
    notifyListeners();
  }

  void clearCart() {
    hymns.clear();
    notifyListeners();
  }
}