import 'package:flutter/material.dart';
import 'package:flutter_hymn/models/cart.dart';
import 'package:flutter_hymn/models/favorite_cart.dart';
import 'package:flutter_hymn/screens/hymn_all.dart';
import 'package:flutter_hymn/screens/hymn_cart.dart';
import 'package:flutter_hymn/screens/hymn_favorites.dart';
import 'package:flutter_hymn/screens/new_hymn.dart';
import 'package:flutter_hymn/screens/search_hymn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: DefaultTabController(length: 5, child: MyHomePage(title: 'Old Hymn Database')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Cart myCart = Cart('new cart');
  late Future<FavoriteCart> _favoriteCartFuture;

  @override
  void initState() {
    super.initState();
    _favoriteCartFuture = FavoriteCart.create();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        bottom: TabBar(tabs: [Tab(icon: Icon(Icons.search)), Tab(icon: Icon(Icons.add)), Tab(icon: Icon(Icons.shopping_bag)), Tab(icon: Icon(Icons.favorite)), Tab(icon: Icon(Icons.library_music))]),
      ),
      body: FutureBuilder<FavoriteCart>(
        future: _favoriteCartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading favorites'));
          }
          final favoriteCart = snapshot.data!;
          return TabBarView(children: [
            SearchHymn(hymns: myCart),
            const NewHymnPage(),
            HymnCartPage(hymns: myCart, favoriteCart: favoriteCart),
            HymnFavoritesPage(favoriteCart: favoriteCart, cart: myCart),
            HymnAllPage(cart: myCart, favoriteCart: favoriteCart),
          ]);
        },
      ),
    );
  }
}
