import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialerNavigationTab extends StatefulWidget {
  @override
  _DialerNavigationTabState createState() => _DialerNavigationTabState();
}

class _DialerNavigationTabState extends State<DialerNavigationTab> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController chapterController = TextEditingController(text: '1');
  final TextEditingController verseController = TextEditingController(text: '1');
  final FocusNode searchFocusNode = FocusNode();
  final FocusNode chapterFocusNode = FocusNode();
  final FocusNode verseFocusNode = FocusNode();

  List<String> filteredBooks = [];
  String? selectedBook;
  bool hasError = false;
  bool _skipNextSelection = false; // Flag to skip auto-selection

  @override
  void initState() {
    super.initState();
    filteredBooks = _getBookList();
    selectedBook = filteredBooks.isNotEmpty ? filteredBooks[0] : null;

    // Add listeners to select all text when focused
    chapterFocusNode.addListener(() {
      if (chapterFocusNode.hasFocus) {
        if (_skipNextSelection) {
          _skipNextSelection = false; // Reset flag
        } else {
          chapterController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: chapterController.text.length,
          );
        }
      } else {
        // Set default to 1 if empty on lost focus
        if (chapterController.text.isEmpty) {
          chapterController.text = '1';
        }
      }
    });

    verseFocusNode.addListener(() {
      if (verseFocusNode.hasFocus) {
        verseController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: verseController.text.length,
        );
      } else {
        // Set default to 1 if empty on lost focus
        if (verseController.text.isEmpty) {
          verseController.text = '1';
        }
      }
    });

    // Add listeners to update UI when values change
    chapterController.addListener(() {
      setState(() {}); // Trigger rebuild to update Go button text
    });

    verseController.addListener(() {
      setState(() {}); // Trigger rebuild to update Go button text
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    chapterController.dispose();
    verseController.dispose();
    searchFocusNode.dispose();
    chapterFocusNode.dispose();
    verseFocusNode.dispose();
    super.dispose();
  }

  void _filterBooks(String query) {
    setState(() {
      hasError = false;

      if (query.isEmpty) {
        filteredBooks = _getBookList();
        selectedBook = filteredBooks.isNotEmpty ? filteredBooks[0] : null;
        return;
      }

      // Try to parse complete reference like "Kidu 2 3", "Kejad 4", "1 Sam 2 5", "1sam3:", "gen1:2"
      final referenceMatch = RegExp(r'^(.+?)(?:\s*(\d+))?(?:[\s:]+(\d+))?:?$').firstMatch(query.trim());

      if (referenceMatch != null) {
        final bookPart = referenceMatch.group(1)?.trim() ?? '';
        final chapterPart = referenceMatch.group(2);
        final versePart = referenceMatch.group(3);

        // Find best matching book with error tolerance
        final matchedBook = _findBestBookMatch(bookPart);

        if (matchedBook != null) {
          filteredBooks = [matchedBook];
          selectedBook = matchedBook;

          // Auto-fill chapter and verse if provided
          if (chapterPart != null) {
            chapterController.text = chapterPart;
            if (versePart != null) {
              verseController.text = versePart;
            } else {
              verseController.text = '1';
            }
          } else {
            // If only book name is provided, reset to defaults
            chapterController.text = '1';
            verseController.text = '1';
          }
        } else {
          // If no book match, filter by book name only
          filteredBooks = _getBookList()
              .where((book) => book.toLowerCase().contains(bookPart.toLowerCase()))
              .toList();
          selectedBook = filteredBooks.isNotEmpty ? filteredBooks[0] : null;
        }
      } else {
        // Simple filtering
        filteredBooks = _getBookList()
            .where((book) => book.toLowerCase().contains(query.toLowerCase()))
            .toList();
        selectedBook = filteredBooks.isNotEmpty ? filteredBooks[0] : null;
      }

      if (filteredBooks.isEmpty) {
        hasError = true;
      }
    });
  }

  String? _findBestBookMatch(String input) {
    final books = _getBookList();
    final inputLower = input.toLowerCase();

    // Exact match
    for (final book in books) {
      if (book.toLowerCase() == inputLower) {
        return book;
      }
    }

    // Starts with match
    for (final book in books) {
      if (book.toLowerCase().startsWith(inputLower)) {
        return book;
      }
    }

    // Contains match with good similarity
    for (final book in books) {
      if (book.toLowerCase().contains(inputLower) && inputLower.length >= 3) {
        return book;
      }
    }

    // Fuzzy match for common abbreviations
    final abbreviations = {
      'kidu': 'Kidung Agung',
      'kejad': 'Kejadian',
      'kel': 'Keluaran',
      'bil': 'Bilangan',
      'ul': 'Ulangan',
      'yos': 'Yosua',
      'hak': 'Hakim-hakim',
      '1sam': '1 Samuel',
      '2sam': '2 Samuel',
      '1 sam': '1 Samuel',
      '2 sam': '2 Samuel',
      'sam': '1 Samuel',
      '1s': '1 Samuel',
      '2s': '2 Samuel',
      'gen': 'Kejadian',
      'g': 'Kejadian',
      'mat': 'Matius',
      'm': 'Matius',
      'mrk': 'Markus',
      'luk': 'Lukas',
      'l': 'Lukas',
      'yoh': 'Yohanes',
      'y': 'Yohanes',
    };

    return abbreviations[inputLower];
  }

  void _handleNumpadPress(String value) {
    // Check if search field has focus - if so, replace chapter field content and focus it
    if (searchFocusNode.hasFocus) {
      if (value == '⌫') {
        // For backspace, clear chapter field and focus it
        chapterController.text = '';
        FocusScope.of(context).requestFocus(chapterFocusNode);
      } else if (value == ':') {
        // For colon, move to verse field
        FocusScope.of(context).requestFocus(verseFocusNode);
      } else {
        // For numbers, replace chapter field content and focus it
        chapterController.text = value;
        _skipNextSelection = true; // Skip the auto-selection on focus
        FocusScope.of(context).requestFocus(chapterFocusNode);
        chapterController.selection = TextSelection.collapsed(offset: value.length);
      }
      return;
    }

    if (value == ':') {
      // Move focus from chapter to verse
      if (chapterFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(verseFocusNode);
      }
    } else if (value == '⌫') {
      // Handle backspace
      if (verseFocusNode.hasFocus) {
        if (verseController.selection.isValid && !verseController.selection.isCollapsed) {
          // If text is selected, delete selected text
          verseController.text = verseController.text.replaceRange(
            verseController.selection.start,
            verseController.selection.end,
            '',
          );
          verseController.selection = TextSelection.collapsed(offset: verseController.selection.start);
        } else if (verseController.text.isNotEmpty) {
          // If no selection, delete last character
          verseController.text = verseController.text.substring(0, verseController.text.length - 1);
        } else {
          // If verse field is empty, move back to chapter field
          FocusScope.of(context).requestFocus(chapterFocusNode);
        }
      } else if (chapterFocusNode.hasFocus) {
        if (chapterController.selection.isValid && !chapterController.selection.isCollapsed) {
          // If text is selected, delete selected text
          chapterController.text = chapterController.text.replaceRange(
            chapterController.selection.start,
            chapterController.selection.end,
            '',
          );
          chapterController.selection = TextSelection.collapsed(offset: chapterController.selection.start);
        } else if (chapterController.text.isNotEmpty) {
          // If no selection, delete last character
          chapterController.text = chapterController.text.substring(0, chapterController.text.length - 1);
        }
      }
    } else {
      // Handle number input with 3 digit limit
      if (verseFocusNode.hasFocus) {
        if (verseController.selection.isValid && !verseController.selection.isCollapsed) {
          // If text is selected, replace selected text
          verseController.text = verseController.text.replaceRange(
            verseController.selection.start,
            verseController.selection.end,
            value,
          );
          final newOffset = (verseController.selection.start + 1).clamp(0, verseController.text.length);
          verseController.selection = TextSelection.collapsed(offset: newOffset);
        } else if (verseController.text.length < 3) {
          // If no selection and under limit, append
          verseController.text += value;
        }
      } else if (chapterFocusNode.hasFocus) {
        if (chapterController.selection.isValid && !chapterController.selection.isCollapsed) {
          // If text is selected, replace selected text
          chapterController.text = chapterController.text.replaceRange(
            chapterController.selection.start,
            chapterController.selection.end,
            value,
          );
          final newOffset = (chapterController.selection.start + 1).clamp(0, chapterController.text.length);
          chapterController.selection = TextSelection.collapsed(offset: newOffset);
        } else if (chapterController.text.length < 3) {
          // If no selection and under limit, append
          chapterController.text += value;
        }
      } else {
        // If neither field is focused, focus chapter field and add the number
        FocusScope.of(context).requestFocus(chapterFocusNode);
        chapterController.text = value;
        final newOffset = value.length.clamp(0, chapterController.text.length);
        chapterController.selection = TextSelection.collapsed(offset: newOffset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search Input field
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87, // Better contrast
              ),
              decoration: InputDecoration(
                hintText: 'Try: 1 Sam 3 16, Kejad 1:1, or 1s2',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600], // Better contrast for hint
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : Colors.transparent,
                    width: hasError ? 2 : 0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : Colors.transparent,
                    width: hasError ? 2 : 0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(
                  Icons.search,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              textInputAction: TextInputAction.go,
              onChanged: (value) {
                _filterBooks(value);
              },
              onSubmitted: (value) {
                _navigateToReference(context, value);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                // Book picker
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const Text('Book', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = filteredBooks[index];
                              final isSelected = book == selectedBook;
                              return ListTile(
                                title: Text(
                                  book,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    decoration: isSelected ? TextDecoration.underline : null,
                                    decorationStyle: isSelected ? TextDecorationStyle.dotted : null,
                                    decorationColor: isSelected ? Theme.of(context).primaryColor : null,
                                  ),
                                ),
                                tileColor: isSelected ? Colors.white : null,
                                onTap: () {
                                  setState(() {
                                    selectedBook = book;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // ChapterVerseInput with Numpad
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const Text('Chapter : Verse', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      // Chapter and Verse input fields
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: chapterController,
                              focusNode: chapterFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Ch',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              textInputAction: TextInputAction.go,
                              readOnly: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              onTap: () {
                                chapterController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: chapterController.text.length,
                                );
                              },
                              onSubmitted: (value) {
                                _navigateToCurrentReference();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(':', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: verseController,
                              focusNode: verseFocusNode,
                              decoration: InputDecoration(
                                hintText: 'V',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              textInputAction: TextInputAction.go,
                              readOnly: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              onTap: () {
                                verseController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: verseController.text.length,
                                );
                              },
                              onSubmitted: (value) {
                                _navigateToCurrentReference();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Numpad
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 3,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          children: [
                            _buildNumpadButton('1'),
                            _buildNumpadButton('2'),
                            _buildNumpadButton('3'),
                            _buildNumpadButton('4'),
                            _buildNumpadButton('5'),
                            _buildNumpadButton('6'),
                            _buildNumpadButton('7'),
                            _buildNumpadButton('8'),
                            _buildNumpadButton('9'),
                            _buildNumpadButton(':'),
                            _buildNumpadButton('0'),
                            _buildNumpadButton('⌫'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: filteredBooks.isEmpty ? null : () {
                _navigateToCurrentReference();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Theme.of(context).primaryColor,
                disabledForegroundColor: Colors.white.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: filteredBooks.isEmpty
                      ? BorderSide.none
                      : const BorderSide(color: Colors.white, width: 2),
                ),
                elevation: 4,
              ),
              child: Text(
                filteredBooks.isEmpty
                    ? 'Go'
                    : 'Go to ${selectedBook ?? 'Book'} ${chapterController.text}:${verseController.text}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: () {
          _handleNumpadPress(text);
        },
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToReference(BuildContext context, String reference) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to: $reference')),
    );
  }

  void _navigateToCurrentReference() {
    if (selectedBook != null) {
      final reference = '$selectedBook ${chapterController.text}:${verseController.text}';
      _navigateToReference(context, reference);
      Navigator.pop(context);
    }
  }

  List<String> _getBookList() {
    return [
      'Kejadian', 'Keluaran', 'Imamat', 'Bilangan', 'Ulangan',
      'Yosua', 'Hakim-hakim', 'Rut', '1 Samuel', '2 Samuel',
      // Add more books as needed
    ];
  }
}
