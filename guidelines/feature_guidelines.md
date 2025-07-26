# Reader Screen Design Instructions (Primary Screen)

Goal: Rebuild this screen (image reference) with our modern, gesture-first pattern. Reader = Home.

---

## 1. Layout Structure
SafeArea
└─ Stack
├─ ScrollView (Verses)
│   └─ Column
│       ├─ ChapterTitle
│       │  ├─ (Genesis 1)  // H1, the chapter use accent color
        │  ├─ PlayAudioButton (right top)
│       │  └─ DisplaySettingsIcon (right top)
│       └─ VerseList (1..N)
│           ├─ VerseRow
│           │   ├─ VerseNumber (superscript, muted)
│           │   └─ VerseText (body)
├─ MenuBar (auto-hide)
└─ FloatingVersePill FAB (bottom-right)

### Spacing & Typography
- Base spacing: 8pt grid.
- BookTitle: 24px / 32 line-height / SemiBold.
- ChapterTitle: 18px / 26 lh / Medium, muted.
- ChapterTitleAccent: 18px / 26 lh / Medium, accent color (red first).
- VerseNumber: 12px / 16 lh / Medium, `#9AA0A6` (light).
- VerseText: 18px / 28 lh / Regular.
- Page horizontal padding: 20px.
- book and chapter titles should be in the local language (e.g., "Kejadian" for Genesis in Indonesian).

---

## 2. Verses

- Play Audio button and Display Settings icon hidden when not at the top of the chapter.

**Behavior:**
- Slide/fade out on scroll down
- Play Audio button toggles audio playback (if available) (phase 2)'
- Display Settings opens a settings modal for font size, line spacing, and theme selection

- **Verse Row**: Each verse is a row with:
  - Superscript verse number (muted color)
  - Verse text (body font)

## 3. MenuBar (Auto-hide)

Use a **minimal bar** to avoid clutter. (We won’t copy YouVersion’s full tab bar.)

**Behavior:**
hide this bar entirely when the scroll is not at the top of the chapter.

use solid background color

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


#### More
- Icon: `more`
- Opens additional options
- it shows a new screen with the following options:
  - theme (light/dark/system)
  - Settings
  - Feedback
  - Help
  - About

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
- **Long press verse** → action sheet

---

## 7. States & Edge Cases

- Verse selection state: highlight background lightly (goldish) with black text.
- No audio available: hide Play button.
- Empty notes/highlights: show “No notes yet” placeholders in managers (not on reader).
- Loading state: skeleton shimmer for first render.

---


---

## 9. Theming

- **Light Mode**: White background, dark text.
- **Dark Mode**: perfect black oled background, light text.
- **System Default**: Follows device theme.

---

## 10. Acceptance Criteria

- [ ] Reader opens on app start.
- [ ] Bottom bars auto-hide correctly.
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
- Search Input field. Can accept:
  - Gen 1:1
  - Mat 6:9
  - Kidung 1:1
- Column
  - BookSelection: a list of books in the current version
  - ChapterVerseInput (numeric keypad with backspace, colon, and Go button)
    - ChapterInput: numeric input for chapter
    - VerseInput: numeric input for verse
    - Numpad
      - 0-9 keys
      - Backspace key
      - Colon key (for chapter:verse)
- Go button: navigates to the selected book/chapter/verse.


when the user use type in the search input field, it will filter the book selection. it also can auto fill the chapter and verse fields. if the user enters a valid book/chapter/verse, it will navigate to that verse when the user taps the Go button. if the user enters an invalid book/chapter/verse, nothing will happen, and the input field will remain focused, highlighting the invalid input, with inline error message. the input field should display a reference example, that is randomly choosen from the available books in the current bible version.

Typing a full reference like `Mat 6:9` will auto-fill the book, chapter, and verse fields, and pressing Go automatically navigate to that verse.

Book and chapter titles should be in the local language (e.g., "Kejadian" for Genesis in Indonesian).


#### Grid
Visual grid of book/chapters/verses, no scroll. Show all books in the current version, then after selecting a book, show chapters, then verses.


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

