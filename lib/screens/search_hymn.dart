import 'package:flutter/material.dart';
import 'package:flutter_hymn/models/cart.dart';
import 'package:flutter_hymn/models/hymn.dart';
import 'package:flutter_hymn/screens/hymn_details.dart';

class SearchHymn extends StatefulWidget {
  final Cart hymns;
  const SearchHymn({super.key, required this.hymns});

  @override
  State<SearchHymn> createState() => _SearchHymnState();
}

class _SearchHymnState extends State<SearchHymn> {
  TextEditingController hymnController = TextEditingController();
  late FocusNode hymnFocusNode;

  @override
  void initState() {
    super.initState();

    hymnFocusNode = FocusNode();
  }

  @override
  void dispose() {
    hymnController.dispose();
    hymnFocusNode.dispose();
    super.dispose();
  }

  void clearAndFocus() {
    hymnController.clear();
    hymnFocusNode.requestFocus();
  }

  Future<Hymn?> grabHymnValidated() async {
    int hymnNumber;
    try {
      hymnNumber = int.parse(hymnController.text);
    } on FormatException {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a hymn number...')));
      clearAndFocus();
      return null;
    }
    Hymn? hymn = await grabHymn(hymnNumber);
    if (hymn == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('That hymn doesn\'t exist...')));
      clearAndFocus();
      return null;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    return hymn;
  }

  Future<void> printHymn() async {
    final Hymn? hymn = await grabHymnValidated();
    if (hymn == null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HymnDetails(hymn: hymn)),
    );
    clearAndFocus();
  }

  Future<void> addHymn() async {
    final Hymn? hymn = await grabHymnValidated();
    if (hymn == null) {
      return;
    }
    widget.hymns.addToCart(hymn);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added ${hymn.number}')));
    clearAndFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: .start,
          children: [
            TextField(
              focusNode: hymnFocusNode,
              controller: hymnController,
              keyboardType: TextInputType.number,
              selectAllOnFocus: true,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Enter a Hymn Number',
              ),
            ),
            Row(
              mainAxisAlignment: .spaceAround,
              children: [
                FilledButton.icon(
                  onPressed: printHymn,
                  icon: Icon(Icons.preview),
                  label: Text('Preview'),
                ),
                FilledButton.icon(
                  onPressed: clearAndFocus,
                  label: Text('Clear'),
                  icon: Icon(Icons.clear),
                ),
                FilledButton.icon(
                  label: Text('Add'),
                  icon: Icon(Icons.add),
                  onPressed: () {
                    addHymn();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
