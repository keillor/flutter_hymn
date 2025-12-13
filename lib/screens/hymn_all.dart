import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hymn/doodads/circle_text.dart';
import 'package:flutter_hymn/models/cart.dart';
import 'package:flutter_hymn/models/favorite_cart.dart';
import 'package:flutter_hymn/models/hymn.dart';
import 'package:sqlite3/sqlite3.dart' hide Row;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HymnAllPage extends StatelessWidget {
  final Cart cart;
  final FavoriteCart favoriteCart;

  const HymnAllPage({
    super.key,
    required this.cart,
    required this.favoriteCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Hymns'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Hymn>>(
          future: _getAllHymns(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading hymns: ${snapshot.error}'),
                  ],
                ),
              );
            }

            final hymns = snapshot.data ?? [];
            if (hymns.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.library_music,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hymns found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedBuilder(
                animation: favoriteCart,
                builder: (context, _) {
                  return ListView.builder(
                    itemCount: hymns.length,
                    itemBuilder: (context, index) {
                      final Hymn h = hymns[index];
                      final isFav = favoriteCart.containsHymn(h.number);
                      return ListTile(
                        key: ValueKey('all-hymn-${h.number}'),
                        contentPadding: const EdgeInsets.all(5.0),
                        leading: CircleText(
                          text: h.number.toString(),
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        title: Text(h.words.substring(0,25)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                cart.addToCart(h);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Added Hymn ${h.number} to cart'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_shopping_cart),
                              tooltip: 'Add to cart',
                            ),
                            IconButton(
                              onPressed: () {
                                FlutterClipboard.copy(h.toString());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied hymn to clipboard'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.content_copy),
                              tooltip: 'Copy',
                            ),
                            IconButton(
                              onPressed: () async {
                                if (isFav) {
                                  await favoriteCart.removeFavoriteHymn(h.number);
                                } else {
                                  await favoriteCart.addFavoriteHymn(h);
                                }
                              },
                              icon: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFav ? Colors.red : null,
                              ),
                              tooltip: isFav
                                  ? 'Remove from favorites'
                                  : 'Add to favorites',
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<Hymn>> _getAllHymns() async {
    final docs = await getApplicationDocumentsDirectory();
    final dbFile = File('${docs.path}/hymns.db');
    final db = sqlite3.open(dbFile.path);

    try {
      final ResultSet rs =
          db.select('SELECT * FROM hymn ORDER BY number ASC');
      return rs
          .map((row) => Hymn(
                row['words'] as String,
                row['number'] as int,
              ))
          .toList();
    } finally {
      db.close();
    }
  }
}
