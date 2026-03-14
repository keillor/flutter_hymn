import 'package:flutter/material.dart';
import 'package:flutter_hymn/models/hymn.dart';

class NewHymnPage extends StatefulWidget {
	const NewHymnPage({super.key});

	@override
	State<NewHymnPage> createState() => _NewHymnPageState();
}

class _NewHymnPageState extends State<NewHymnPage> {
	final TextEditingController _titleController = TextEditingController();
	final TextEditingController _bodyController = TextEditingController();

	@override
	void dispose() {
		_titleController.dispose();
		_bodyController.dispose();
		super.dispose();
	}

  Future<void> addHymn() async {
    int hymnNumber = 0;
    String hymnText = '';
    try {
      hymnNumber = int.parse(_titleController.text);
    } on FormatException {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hymn number must be an integer.'), action: SnackBarAction(label: 'CLEAR', onPressed: () {ScaffoldMessenger.of(context).clearSnackBars();})));
      return;
    }
    if(_bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hymn text is required...'), action: SnackBarAction(label: 'CLEAR', onPressed: () {ScaffoldMessenger.of(context).clearSnackBars();})));
      return;
    }

    hymnText = _bodyController.text;

    Hymn? hymn = await grabHymn(hymnNumber);
    if(hymn != null) {
      //ask if hymn should be replaced.
      final result = await _showMyDialog();
      if(result == false) {
        return;
      }
    }


    if(await saveHymn(hymnNumber, hymnText)) {
      //it saved
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving hymn...'), action: SnackBarAction(label: 'CLEAR', onPressed: () {ScaffoldMessenger.of(context).clearSnackBars();})));
    }
    return;
  }

  Future<bool> _showMyDialog() async {
    final bool? dialogResult = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hymn number already exists!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to replace the existing hymn with the provided one?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Replace old hymn'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            TextButton(
              child: const Text('Discard new hymn'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );

    return dialogResult ?? false;
  }


	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Add Hymn'),
			),
      floatingActionButton: FloatingActionButton(
        onPressed: addHymn,
        tooltip: 'Save Hymn',
        child: const Icon(Icons.save),
      ),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							const Text(
								'Title',
								style: TextStyle(fontWeight: FontWeight.w600),
							),
							const SizedBox(height: 8),
							TextField(
								controller: _titleController,
								maxLines: 1,
                keyboardType: TextInputType.number,
								textCapitalization: TextCapitalization.sentences,
								decoration: const InputDecoration(
									border: OutlineInputBorder(),
									hintText: 'Enter hymn number',
								),
							),
							const SizedBox(height: 16),
							const Text(
								'Hymn Text',
								style: TextStyle(fontWeight: FontWeight.w600),
							),
							const SizedBox(height: 8),
							Expanded(
								child: TextField(
                  textAlign: .start,
                  textAlignVertical: .top,
									controller: _bodyController,
									keyboardType: TextInputType.multiline,
									textInputAction: TextInputAction.newline,
									minLines: null,
									maxLines: null,
									expands: true,
									decoration: const InputDecoration(
										alignLabelWithHint: true,
										border: OutlineInputBorder(),
										hintText: 'Enter hymn text.',
									),
								),
							),
						],
					),
				),
			),
		);
	}
}