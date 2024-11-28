import 'package:flutter/material.dart';

class TextEditorModel extends ChangeNotifier {
  final List<_TextData> _textDataList = [];
  int _currentIndex = -1; // Keeps track of the currently selected text.

  final List<List<_TextData>> _history = [];
  int _historyIndex = -1;

  // Font customization options for new or selected text
  String _selectedFont = 'Roboto';
  double _fontSize = 16.0;
  bool _isBold = false;
  bool _isItalic = false;

  // Available fonts
  final List<String> fonts = ['Roboto', 'Arial', 'Courier', 'Times New Roman'];

  String get selectedFont => _selectedFont;
  double get fontSize => _fontSize;
  bool get isBold => _isBold;
  bool get isItalic => _isItalic;

  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  // Add new text to the canvas
  void addText(String text, Offset position) {
    _textDataList.add(
      _TextData(
        text: text,
        position: position,
        font: _selectedFont,
        fontSize: _fontSize,
        isBold: _isBold,
        isItalic: _isItalic,
      ),
    );
    _currentIndex = _textDataList.length - 1; // Select the newly added text
    _saveState();
    notifyListeners();
  }

  // Select a text widget
  void selectText(int index) {
    if (index < 0 || index >= _textDataList.length) return;

    _currentIndex = index;
    final selectedText = _textDataList[_currentIndex];

    // Update formatting options to match the selected text
    _selectedFont = selectedText.font;
    _fontSize = selectedText.fontSize;
    _isBold = selectedText.isBold;
    _isItalic = selectedText.isItalic;

    notifyListeners();
  }

  // Update the formatting of the selected text
  void updateSelectedText() {
    if (_currentIndex < 0 || _currentIndex >= _textDataList.length) return;

    _textDataList[_currentIndex] = _textDataList[_currentIndex].copyWith(
      font: _selectedFont,
      fontSize: _fontSize,
      isBold: _isBold,
      isItalic: _isItalic,
    );
    _saveState();
    notifyListeners();
  }

  // Drag text to a new position
  void moveText(int index, Offset newPosition) {
    if (index < 0 || index >= _textDataList.length) return;

    _textDataList[index] = _textDataList[index].copyWith(position: newPosition);
    notifyListeners();
  }

  // Undo functionality
  void undo() {
    if (!canUndo) return;

    _historyIndex--;
    _loadState();
    notifyListeners();
  }

  // Redo functionality
  void redo() {
    if (!canRedo) return;

    _historyIndex++;
    _loadState();
    notifyListeners();
  }

  // Change font for selected text
  void changeFont(String font) {
    _selectedFont = font;
    updateSelectedText();
  }

  // Increase font size for selected text
  void increaseFontSize() {
    _fontSize += 2.0;
    updateSelectedText();
  }

  // Decrease font size for selected text
  void decreaseFontSize() {
    if (_fontSize > 2.0) {
      _fontSize -= 2.0;
      updateSelectedText();
    }
  }

  // Toggle bold for selected text
  void toggleBold() {
    _isBold = !_isBold;
    updateSelectedText();
  }

  // Toggle italic for selected text
  void toggleItalic() {
    _isItalic = !_isItalic;
    updateSelectedText();
  }

  // Get the list of text widgets to display on the canvas
  List<Widget> get textWidgets {
    return _textDataList.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return Positioned(
        left: data.position.dx,
        top: data.position.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            moveText(index, data.position + details.delta);
          },
          onTap: () => selectText(index), // Select text on tap
          child: Text(
            data.text,
            style: TextStyle(
              fontFamily: data.font,
              fontSize: data.fontSize,
              fontWeight: data.isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: data.isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      );
    }).toList();
  }

  // Save the current state for undo/redo
  void _saveState() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _history.add(List<_TextData>.from(_textDataList));
    _historyIndex++;
  }

  // Load the current state for undo/redo
  void _loadState() {
    if (_historyIndex < 0 || _historyIndex >= _history.length) return;

    _textDataList.clear();
    _textDataList.addAll(_history[_historyIndex]);
  }
}

// Internal class to store data about each text widget
class _TextData {
  final String text;
  final Offset position;
  final String font;
  final double fontSize;
  final bool isBold;
  final bool isItalic;

  _TextData({
    required this.text,
    required this.position,
    required this.font,
    required this.fontSize,
    required this.isBold,
    required this.isItalic,
  });

  // Helper method to copy data with modifications
  _TextData copyWith({
    String? text,
    Offset? position,
    String? font,
    double? fontSize,
    bool? isBold,
    bool? isItalic,
  }) {
    return _TextData(
      text: text ?? this.text,
      position: position ?? this.position,
      font: font ?? this.font,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
    );
  }
}
