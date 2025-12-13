import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hymn/doodads/circle_text.dart';
import 'package:flutter_hymn/models/cart.dart';
import 'package:flutter_hymn/models/favorite_cart.dart';
import 'package:flutter_hymn/models/hymn.dart';

class HymnCartPage extends StatelessWidget {
  final Cart hymns;
  final FavoriteCart favoriteCart;
  const HymnCartPage({super.key, required this.hymns, required this.favoriteCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hymn Cart')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedBuilder(
            animation: hymns,
            builder: (context, _) {
              return ReorderableListView.builder(
                itemCount: hymns.hymns.length,
                itemBuilder: (context, index) {
                  final Hymn h = hymns.hymns[index];
                  return ListTile(
                    key: ValueKey('hymn-${h.number}'),
                    contentPadding: const EdgeInsets.all(5.0),
                    leading: CircleText(
                      text: h.number.toString(),
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: AnimatedBuilder(
                        animation: favoriteCart,
                        builder: (context, _) {
                          final isFav = favoriteCart.containsHymn(h.number);
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : null,
                            ),
                            onPressed: () async {
                              if (isFav) {
                                await favoriteCart.removeFavoriteHymn(h.number);
                              } else {
                                await favoriteCart.addFavoriteHymn(h);
                              }
                            },
                          );
                        },
                      ),
                    ),
                    title: Text('${h.words.substring(0, 25)}...'),
                    onTap: () {
                      FlutterClipboard.copy(h.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied hymn to clipboard'),
                        ),
                      );
                    },
                    onLongPress: () {
                      hymns.removeAt(index);
                    },
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  hymns.move(oldIndex, newIndex);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
