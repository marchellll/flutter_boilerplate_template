

# TODO (Actionable Tasks)

## 0. Project Bootstrap
- [ ] flutter create bible_app
- [ ] Add packages: sqlite/hive, file_picker, just_audio, flutter_local_notifications
- [ ] Set min SDKs, iOS permissions, Android storage perms

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

## 4. Reader (Home)
- [ ] Full-screen scroll. Verse blocks with small superscript numbers
- [ ] Gestures:
  - Swipe L/R to next/prev chapter
  - Tap status/top to reveal app bar
  - Long-press verse → VerseActions sheet
- [ ] Floating verse pill FAB → open NavModal

## 5. NavModal (Direct / Dialer / Grid)
- [ ] Direct: single text input “Mat 6:9”
- [ ] Dialer: 3 wheel pickers
- [ ] Grid: grid of chapters, then verses
- [ ] Smooth slide/animate

## 6. Highlights & Notes
- [ ] Long-press verse → choose highlight color / add note
- [ ] Store locally
- [ ] Manager page: tabs (Highlights / Notes), filter, jump to verse

## 7. Share as Image
- [ ] Templates (5 backgrounds)
- [ ] Render verse text on canvas & export/share PNG

## 8. Daily Verse + Notification
- [ ] Bundled daily verse list
- [ ] Schedule local notification at user-set time

## 9. Audio (Optional)
- [ ] Bundle sample MP3
- [ ] Mini-player dock in Reader
- [ ] Full player screen (speed, seek)

## 10. Settings & Legal
- [ ] Theme (light/dark/system), font size, line spacing
- [ ] Notification time picker
- [ ] ToS screen; show on first launch (must accept)

## 11. Dev Scripts (Optional)
- [ ] usfm_to_usx.py
- [ ] usx_to_sqlite.dart
- [ ] Import logging

## ✅ Phase 1 Done When
- [ ] Android & iOS build ok
- [ ] TSI & KJV render correctly
- [ ] Reader = home, gestures work
- [ ] Import all listed formats to DB
- [ ] Highlights, notes, text/image share work
- [ ] Search returns correct verses
- [ ] Daily verse + notification works
- [ ] Theme/font/spacing adjustable
- [ ] Optional audio works
- [ ] ToS shown; no illegal texts bundled
- [ ] No backend calls

## Phase 2 (Defer)
- Dynamic downloads (API)
- Devotionals/reading plans from CMS
- Cloud sync (auth, merge)
- Smart search (server)
- Community/comments
- Monetization (IAP/donations)