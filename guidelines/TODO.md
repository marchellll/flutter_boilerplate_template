

# TODO (Actionable Tasks)

**RECENT PROGR## 5. NavModal (Direct / Dialer / Grid) ⚠️ NEEDS UI REDESIGN
- [x] UI structure with TabBar and 3 modes created
- [x] Functional implementation works (navigation logic)
- [ ] **UI LOOKS BAD**: Current design is shit and needs visual redesign
- [ ] **TODO**: Redesign UI/UX for better visual appeal and usability
- [x] Direct: single text input "Mat 6:9" - works but ugly
- [x] Dialer: 3 wheel pickers - works but ugly
- [x] Grid: grid of chapters, then verses - works but ugly
- [x] Smooth slide/animate

## 6. Highlights & Notes ✅ UI DONE: Refactored bible_reader_screen.dart into modular widgets (80% code reduction), removed TODO boilerplate features, moved global components to core/widgets. App architecture now clean and focused on Bible reading.

## 0. Project Bootstrap ✅ DONE
- [x] flutter create bible_app
- [x] Add packages: flutter_bloc, get_it, injectable, go_router, etc.
- [x] Set up project structure with features/core architecture

## 1. Data Layer
- [ ] Schema: books, chapters, verses, notes, highlights, metadata
- [ ] Implement DB service (CRUD + FTS for search)
- [ ] Import pipeline: save parsed text to DB

## 2. Built-in Versions
- [ ] Convert TSI & KJV → SQLite/JSON
- [ ] Bundle in assets & load on first run
- [ ] Show in VersionSelector

## 3. Import Feature
- [ ] UI: “Import Bible File”
- [ ] detectFormat(filePath) → enum {USFM, USX, OSIS, YES_V1, YES_V2, PBD, UNKNOWN}
- [ ] Parser funcs (throw on encrypted PBD/YES):
  - parseUsfm()
  - parseUsx()
  - parseOsis()
  - parseYesV1()
  - parseYesV2()
  - parsePbd()
- [ ] Persist to DB; add to Version list

## 4. Reader (Home) ✅ MOSTLY DONE
- [x] Full-screen scroll. Verse blocks with small superscript numbers
- [x] Gestures:
  - [x] Swipe L/R to next/prev chapter
  - [x] Tap status/top to reveal app bar (auto-hide menu bar)
  - [x] Long-press verse → VerseActions sheet
- [x] Floating verse pill FAB → open NavModal
- [x] Refactored into modular widgets (8 components)
- [x] Clean architecture with proper separation of concerns

## 5. NavModal (Direct / Dialer / Grid)
- [ ] Direct: single text input “Mat 6:9”
- [ ] Dialer: 3 wheel pickers
- [ ] Grid: grid of chapters, then verses
- [ ] Smooth slide/animate

## 6. Highlights & Notes ✅ UI DONE
- [x] Long-press verse → choose highlight color / add note (VerseActionSheet)
- [x] UI components for verse interactions (highlight, bookmark, note, copy, share, image)
- [ ] Store locally (needs data layer implementation)
- [ ] Manager page: tabs (Highlights / Notes), filter, jump to verse

## 7. Share as Image ✅ UI DONE
- [x] Share option in VerseActionSheet
- [ ] Templates (5 backgrounds) - needs implementation
- [ ] Render verse text on canvas & export/share PNG

## 8. Daily Verse + Notification
- [ ] Bundled daily verse list
- [ ] Schedule local notification at user-set time

## 9. Audio (Optional)
- [ ] Bundle sample MP3
- [ ] Mini-player dock in Reader
- [ ] Full player screen (speed, seek)

## 10. Settings & Legal ✅ UI STRUCTURE DONE
- [x] App structure with settings/more modal (AppMoreModal in core/widgets)
- [x] Navigation structure for theme, settings, feedback, help, about
- [ ] Theme (light/dark/system), font size, line spacing - needs implementation
- [ ] Notification time picker
- [ ] ToS screen; show on first launch (must accept)

## 11. Dev Scripts (Optional)
- [ ] usfm_to_usx.py
- [ ] usx_to_sqlite.dart
- [ ] Import logging

## ✅ Phase 1 Progress Update
**COMPLETED:**
- [x] Clean architecture with feature-based structure
- [x] Removed TODO boilerplate, focused on Bible app
- [x] Bible reader UI with 8 modular widgets
- [⚠️] Navigation modal structure (works functionally but UI looks bad)
- [x] Verse interaction UI (highlight, notes, share)
- [x] Global app navigation (bottom bar + more modal)
- [x] Gesture-based navigation (swipe chapters, auto-hide bars)
- [x] Version picker modal structure

**NEXT PRIORITIES:**
1. **Data Layer** - Implement actual Bible database and BLoC logic
2. **Navigation Modal UI REDESIGN** - Works functionally but looks bad, needs visual redesign
3. **Built-in Versions** - Add TSI & KJV Bible text data
4. **Import Feature** - File parsing for USFM, USX, OSIS formats
5. **Functional Implementation** - Make UI components actually work with data

**CURRENT STATE**: UI/UX framework complete, needs data layer integration

## Phase 2 (Defer)
- Dynamic downloads (API)
- Devotionals/reading plans from CMS
- Cloud sync (auth, merge)
- Smart search (server)
- Community/comments
- Monetization (IAP/donations)