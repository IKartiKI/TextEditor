import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'text_editor_model.dart'; // Import the updated TextEditorModel

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TextEditorModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Text Editor',
      home: TextEditorScreen(),
    );
  }
}

class TextEditorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textEditorModel = Provider.of<TextEditorModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Text Editor'),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: textEditorModel.canUndo ? textEditorModel.undo : null,
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: textEditorModel.canRedo ? textEditorModel.redo : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          ...textEditorModel.textWidgets, // Add text widgets to the canvas
          Align(
            alignment: Alignment.bottomCenter,
            child: _TextEditorToolbar(),
          ),
          Positioned(
            bottom: 100, // Adjust position above the toolbar
            right: 16, // Align to the right side
            child: FloatingActionButton(
              onPressed: () => _showAddTextDialog(context),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTextDialog(BuildContext context) {
    final textController = TextEditingController();
    final textEditorModel =
        Provider.of<TextEditorModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Text'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'Enter your text',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  textEditorModel.addText(
                    textController.text,
                    Offset(50, 50), // Default position for new text
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _TextEditorToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textEditorModel = Provider.of<TextEditorModel>(context);

    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Font Dropdown
          DropdownButton<String>(
            value: textEditorModel.selectedFont,
            items: textEditorModel.fonts
                .map(
                  (font) => DropdownMenuItem(
                    value: font,
                    child: Text(font),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) textEditorModel.changeFont(value);
            },
          ),
          // Font Size Buttons
          IconButton(
            icon: Icon(Icons.text_decrease),
            onPressed: textEditorModel.decreaseFontSize,
          ),
          Text(
            '${textEditorModel.fontSize.toInt()}',
            style: TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: Icon(Icons.text_increase),
            onPressed: textEditorModel.increaseFontSize,
          ),
          // Bold Button
          IconButton(
            icon: Icon(
              Icons.format_bold,
              color: textEditorModel.isBold ? Colors.blue : Colors.black,
            ),
            onPressed: textEditorModel.toggleBold,
          ),
          // Italic Button
          IconButton(
            icon: Icon(
              Icons.format_italic,
              color: textEditorModel.isItalic ? Colors.blue : Colors.black,
            ),
            onPressed: textEditorModel.toggleItalic,
          ),
        ],
      ),
    );
  }
}
