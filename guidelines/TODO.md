# TODO (Actionable Tasks)

**RECENT PROGRESS** ## 5. NavModal (Direct / Dialer / Grid) ⚠️ PARTIALLY DONE
- [x] UI structure with TabBar and 3 modes created
- [x] Functional implementation works (navigation logic)
- [x] **Dialer tab**: UI LOOKS GOOD - smart parsing, numpad input, book selection
- [ ] **Grid tab**: UI LOOKS BAD - needs visual redesign
- [ ] **TODO**: Redesign Grid tab UI/UX for better visual appeal
- [ ] Direct: single text input "Mat 6:9" - not yet works
- [x] Dialer: 3-column layout with search, book picker, numpad - WORKS WELL
- [ ] Grid: grid of chapters, then verses - LOOKS BAD
- [x] Smooth slide/animate
- [x] Refactored into modular widgets (navigation_modal.dart + dialer_navigation_tab.dart + grid_navigation_tab.dart)

## 6. Highlights & Notes ✅ UI DONE: Refactored bible_reader_screen.dart into modular widgets (80% code reduction), removed TODO boilerplate features, moved global components to core/widgets. App architecture now clean and focused on Bible reading.

## 0. Project Bootstrap ✅ DONE
- [x] flutter create bible_app
- [x] Add packages: flutter_bloc, get_it, injectable, go_router, etc.
- [x] Set up project structure with features/core architecture

## 1. Data Layer ✅ ETL PIPELINE ENHANCED
- [x] **ETL Pipeline**: Created `scripts/bible_etl/` with multi-source Bible data pipeline
- [x] **Schema Enhancement**: Updated to support version-specific books with localized names
- [x] **Entity Synchronization**: 
  - [x] Updated Book entity: removed redundant `nameLocal`, added `code`, `versionId`, localized name fields
  - [x] Created Footnote entity for Bible footnotes and cross-references
  - [x] Enhanced Verse entity with footnotes reference
  - [x] Removed redundant BookName entity (merged into Book)
- [x] **Database Schema**: books, chapters, verses, footnotes, notes, highlights, metadata with FTS5 search
- [x] **USFX Parser**: Enhanced with BCV attribute parsing, BookNames.xml support, footnote extraction
- [x] **Multi-format Support**: USFM, USFX, USX, OSIS parsers implemented
- [x] **Search Optimization**: FTS5 virtual tables for full-text search
- [x] **Verification**: Enhanced verify.js with content quality checks, duplicate detection, verse validation
- [x] **Idempotent Pipeline**: Safe to rerun, declarative source management
- [⚠️] **ISSUE**: Current pipeline shows 0 verses extracted - USFX parser needs debugging
- [ ] **TODO**: Debug USFX verse extraction (BCV attribute parsing not working correctly)
- [ ] **TODO**: Implement BLoC/repository layer for database operations
- [ ] **TODO**: Run successful ETL pipeline to generate actual bible.db with verses

## 2. Built-in Versions ⚠️ PIPELINE READY
- [x] **ETL Infrastructure**: Pipeline supports multiple Bible versions
- [x] **Source Configuration**: `bible_sources.json` with KJV, WEB, ASV sources
- [ ] **TODO**: Run pipeline to download and process TSI & KJV
- [ ] **TODO**: Verify database deployment to `assets/bibles/`
- [ ] **TODO**: Show in VersionSelector widget

## 3. Import Feature
- [ ] UI: "Import Bible File"
- [x] **Format Detection**: detectFormat() implemented in ETL parser
- [x] **Multi-format Parsers**: USFM, USX, OSIS, text parsers ready
- [ ] **TODO**: Create Flutter UI for file import
- [ ] **TODO**: Integrate ETL parsers into Flutter app
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
- [⚠️] Navigation modal structure (UI looks bad)
- [x] Verse interaction UI (highlight, notes, share)
- [x] Global app navigation (bottom bar + more modal)
- [x] Gesture-based navigation (swipe chapters, auto-hide bars)
- [x] Version picker modal structure
- [x] **🆕 ETL Pipeline**: Complete multi-source Bible data processing system
- [x] **🆕 Database Schema**: Optimized SQLite with FTS5 search capabilities
- [x] **🆕 Entity Generation**: Auto-generated Flutter domain entities

**NEXT PRIORITIES:**
1. **Run ETL Pipeline** - Execute `npm run build` to generate bible.db with real data
2. **BLoC Integration** - Implement repository pattern and state management for database
3. **Grid Navigation UI REDESIGN** - Dialer tab looks good, but Grid tab needs visual reimplementation
4. **Functional Implementation** - Connect UI components to actual Bible data
5. **Import Feature UI** - Create Flutter interface for the ETL import capabilities

**CURRENT STATE**:
- UI/UX framework complete ✅
- **Data pipeline infrastructure complete** ✅
- **Needs**: Execute ETL pipeline + implement Flutter data layer

## Phase 2 (Defer)
- Dynamic downloads (API)
- Devotionals/reading plans from CMS
- Cloud sync (auth, merge)
- Smart search (server)
- Community/comments
- Monetization (IAP/donations)