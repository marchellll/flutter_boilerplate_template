# Reader Screen Design Instructions (Primary Screen)

Goal: Rebuild this screen (image reference) with our modern, gesture-first pattern. Reader = Home.

---

## 1. Layout Structure
SafeArea
└─ Stack
├─ ScrollView (verses)
│   └─ Column
│       ├─ BookTitle (Genesis)        // H1
│       ├─ ChapterTitle (Chapter 1)   // H2
│       └─ VerseList (1..N)
│           ├─ VerseRow
│           │   ├─ VerseNumber (superscript, muted)
│           │   └─ VerseText (body)
├─ TopBar (auto-hide)
├─ MenuBar (auto-hide)
└─ FloatingVersePill FAB (bottom-right)

### Spacing & Typography
- Base spacing: 8pt grid.
- BookTitle: 24px / 32 line-height / SemiBold.
- ChapterTitle: 18px / 26 lh / Medium, muted.
- VerseNumber: 12px / 16 lh / Medium, `#9AA0A6` (light).
- VerseText: 18px / 28 lh / Regular.
- Page horizontal padding: 20px.
- book and chapter titles should be in the local language (e.g., "Kejadian" for Genesis in Indonesian).

---

## 2. Top Bar (Auto-hide)

**Visible on:**
- User at the top of the screen
- Scroll up a little
- Tap status bar

**Contents (left→right):**
- Version selector text button: `ESV` (our default: `TSI/KJV`)
- Current reference label: `Genesis 1` (book + chapter)
- Play Audio button (if audio available)
- Display Settings icon (font size, line spacing, color theme)

**Behavior:**
- Slide/fade out on scroll down
- Slide in on scroll up or status-bar tap
- Play Audio button toggles audio playback (if available) (phase 2)'
- Display Settings opens a settings modal for font size, line spacing, and theme selection


---

## 3. MenuBar (Auto-hide)

Use a **minimal bar** to avoid clutter. (We won’t copy YouVersion’s full tab bar.)

**Behavior:**
hide this bar entirely when the top bar is hidden, and show it when the top bar is visible.

### Menu Items (left→right):

#### Home
- Icon: `home`
- Shows Welcome screen with daily verse, reading plans streak, etc.


#### Bible
- Icon: `book`
- Opens Bible reader (home screen)
- Shows last read book/chapter
- The Bible reader is the home screen, so this will always be the first screen shown.

#### Plans
- Icon: `calendar`
- Opens reading plans and devotionals
- Shows current plan progress, next reading
- Allows starting new plans

#### Search (phase 2)
- Icon: `search`
- Opens magic search
- Allows searching by verse, keyword, topic
- AI powered search suggestions

---

## 4. Floating Verse Pill FAB

- Shape: Rounded pill bottom-right safe margin, on top of the menu bar.
- Tapping the version selector opens a version picker modal
- Tapping the current reference opens the Navigation Modal (Direct/Dialer/Grid)
- Move up and down with scroll, but always visible, slightly dimmed when the top bar is hidden.
- Content: `ESV | Genesis 1` (or current version/ref).
- Tap → open **Navigation Modal** (DirectDialer / Grid).
- Drag up to expand into Grid Navigation (Drag mode).
- book and chapter titles should be in the local language (e.g., "Kejadian" for Genesis in Indonesian).


---

## 5. Verse Interaction

### Long-press OR double-tap verse text.

**Show:** Bottom Action Sheet:

Add close button (X) at top right.

Buttons (row or grid):
- Highlight (opens color picker)
- Save in Marker
- Add/Edit Note
- Copy Text
- Share Text
- Share as Image

Data to pass: book, chapter, verse number, version id.

### Swipe Left/Right
- **Left**: Next chapter
- **Right**: Previous chapter
- **Behavior**: Smooth transition, no page reload.
- use slide animation for chapter transitions


---

## 6. Gestures

- **Swipe Left/Right (anywhere on reader)** → next/previous chapter
- **Tap top status area** → reveal top bar
- **Long press verse** → action sheet

---

## 7. States & Edge Cases

- Verse selection state: highlight background lightly (`#FFF9C4` for yellow).
- No audio available: hide Play button.
- Empty notes/highlights: show “No notes yet” placeholders in managers (not on reader).
- Loading state: skeleton shimmer for first render.

---


---

## 9. Theming

- **Light Mode**: White background, dark text.
- **Dark Mode**: Dark background, light text.
- **System Default**: Follows device theme.

---

## 10. Acceptance Criteria

- [ ] Reader opens on app start.
- [ ] Top & bottom bars auto-hide correctly.
- [ ] Swipe L/R chapter nav works.
- [ ] Floating pill opens Nav Modal.
- [ ] Long-press verse opens Action Sheet.
- [ ] Performance: 60fps scroll on mid-tier Android.

---

## 11. Navigation Modal


**Behavior:**
- Modal slides up from bottom.
- Close button (X) at top right, unless in drag mode.
- Tap outside modal to dismiss.

### Modes

#### DirectDialer

Top to bottom:
- Book selector (2 text input, left for book, right for chapter and verse)
- Chapter and Verse selector (numeric keypad with backspace, colon, and Go button)


Numeric keypad for verse entry. Quick jump to a specific verse. Can fuzzy match book names, chapter numbers, and verse numbers. Text input field with auto-complete suggestions. Text input also act as book selector.

If the user use the text input field, it will show a list of suggestions based on the input. If the user selects a suggestion, it will navigate to that verse.

If the user enters a valid book/chapter/verse, it will navigate to that verse.

If the user enters an invalid book/chapter/verse, nothing will happen, and the input field will remain focused.

If the user select a book from the list, the user can use the dialer to select the chapter and verse.

Typing a full reference like `Mat 6:9` will auto-fill the book, chapter, and verse fields, and automatically navigate to that verse.

Book and chapter titles should be in the local language (e.g., "Kejadian" for Genesis in Indonesian).


#### Grid
Visual grid of chapters/verses, no scroll. Show all chapters in a book, then verses in a chapter after book selected.

In drag mode, hover for 2 seconds equals tapping it. Layering the whole screen. The screen if big (tablet/desktop) use sheet modal, otherwise full screen.


#### Marker

- Icon: `marker`
- Opens a list of saved markers (highlights, notes)
- Allows jumping to specific markers in the current book/chapter
- Supports filtering by type (highlight/note) and color
- Tapping a marker navigates to that verse
- Long-press a marker to edit or delete it
- Supports drag-and-drop reordering of markers
- Supports bulk actions (delete all, export)
- Supports sharing markers as images or text
- Supports searching markers by text or color
- Supports filtering markers by color
- Supports sorting markers by date created or modified
- Supports exporting markers to JSON or CSV format
- Supports importing markers from JSON or CSV format
- Supports syncing markers with cloud storage (phase 2)

