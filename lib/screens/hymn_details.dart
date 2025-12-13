import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hymn/models/hymn.dart';

class HymnDetails extends StatelessWidget{
  final Hymn hymn;
  const HymnDetails({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    FlutterClipboard.copy('${hymn.number}\n${hymn.words}');
    return Scaffold(
      appBar: AppBar(title: Text('Hymn ${hymn.number}')),
      body: Center(child: SingleChildScrollView(child: Text(hymn.words),)),
    );
  }
  
}