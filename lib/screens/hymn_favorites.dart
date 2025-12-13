import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hymn/doodads/circle_text.dart';
import 'package:flutter_hymn/models/cart.dart';
import 'package:flutter_hymn/models/favorite_cart.dart';
import 'package:flutter_hymn/models/hymn.dart';

class HymnFavoritesPage extends StatelessWidget {
  final FavoriteCart favoriteCart;
  final Cart cart;
  
  const HymnFavoritesPage({super.key, required this.favoriteCart, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Hymns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => favoriteCart.loadFavorites(),
            tooltip: 'Refresh favorites',
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: favoriteCart,
          builder: (context, _) {
            if (favoriteCart.hymns.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add hymns to your favorites to see them here',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                    itemCount: favoriteCart.hymns.length,
                    itemBuilder: (context, index) {
                      final Hymn h = favoriteCart.hymns[index];
                      return ListTile(
                        key: ValueKey('favorite-hymn-${h.number}'),
                        contentPadding: const EdgeInsets.all(5.0),
                        leading: CircleText(
                          text: h.number.toString(),
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        title: Text('${h.words.substring(0,25)}...'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                cart.addToCart(h);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added Hymn ${h.number} to cart'),
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
                                await favoriteCart.removeFavoriteHymn(h.number);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Removed Hymn ${h.number} from favorites'),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.favorite),
                              color: Colors.red,
                              tooltip: 'Remove from favorites',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            );
          },
        ),
      ),
    );
  }
}
