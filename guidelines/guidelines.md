# 👩‍💻 Agent Guidelines (Bible App Project)

These rules tell you (the agentic coder) how to act, what to build, when to ask, and how to deliver.

---

## 0. Mission

- Build an **offline-first Flutter Bible app**.
- **Reader is the home screen** (full-screen, gesture-first UI).
- Bundle **TSI + KJV** only (license-safe).
- Allow user-imported Bible files: **USFM, USX, OSIS, YES v1/v2, PBD** (reject encrypted/unknown).
- **No backend in Phase 1**. Everything local.
- Stay legally safe: show disclaimer; never bundle proprietary texts.

---

## 1. Operating Principles

1. **Clarity over cleverness**: choose explicit, readable code.
2. **Local-first**: never add network calls unless Phase 2 is enabled.
3. **Fail noisily on imports**: invalid or encrypted files → clear error.
4. **Ask only when ambiguous** (see §7).
5. **Keep app fast**: cache, memoize, index DB, avoid unnecessary rebuilds.
6. **Accessibility**: adjustable fonts, color contrast checked.

---

## 2. Project Structure (suggested)

lib/
core/
theme/
utils/
db/
features/
reader/
navigation/
import/
search/
highlights/
notes/
share_image/
audio/
settings/
legal/
widgets/
scripts/        # converters, data prep
assets/
bibles/       # bundled TSI/KJV db/json
templates/    # verse image backgrounds

---

## 3. Data & Parsing

- **DB Schema**:
  - `books(id, name, order)`
  - `chapters(id, book_id, number)`
  - `verses(id, chapter_id, number, text)`
  - `notes(id, verse_id, text, ts)`
  - `highlights(id, verse_id, color, ts)`
  - `meta(version_id, lang, name, source, license)`
- **FTS**: Use SQLite FTS5 or similar; index `verses.text`.

- **Format Detection**:
  - File extension first; fallback to content sniffing.
  - Enum: `{USFM, USX, OSIS, YES_V1, YES_V2, PBD, UNKNOWN}`

- **Parsers**: Separate pure functions. Unit test them.
  - Reject encrypted/DRM’d PBD/YES.

---

## 4. UI/UX Conventions

- **Reader = Home**:
  - Auto-hide top bar, gesture navigation.
  - Swipe L/R for chapter; tap status bar to reveal app bar.
  - Long-press verse → Action Sheet.

- **Navigation Modal** (Direct / Dialer / Grid):
  - Present as bottom sheet or full-screen modal.
  - Smooth animation, large touch targets.

- **Edge Swipe Drawer / Pull-down Overlay**:
  - Houses global nav (Search, Import, Versions, Notes/Highlights, Settings).

- **Floating Verse Pill FAB**:
  - Shows current ref; tap → open nav modal.

- **Highlight Colors**: Provide 4+ presets.

- **Share as Image**: Use Canvas, 5 templates.

- **Notifications**: Use local notifications only.

---

## 5. Legal / Terms

Show this somewhere in the app (e.g., Settings > Legal):

> “This app allows importing Bible files. You are responsible for ensuring you have legal rights to any file you load. The developer assumes no liability for unauthorized content.”

---

## 6. Coding Standards

- Dart/Flutter best practices:
  - Null-safety, lints (`flutter_lints`).
  - Separate UI (widgets) and logic (controllers/services).

- Commits: Conventional Commits (`feat:`, `fix:`, `chore:`).
- Tests: Unit for parsers, widget tests for Reader & nav modal.

---

## 7. When to Ask the User

Ask only if:
- A required file/format is unknown or malformed.
- UI/UX conflict arises with existing guidelines.
- License ambiguity for a new translation.
- Performance trade-offs need approval (e.g., huge DB vs. segmented files).

Otherwise, proceed autonomously.

---

## 8. Phase Gates

### Phase 1 (Offline Core)
- See `TODO.md` and “MVP Phase 1 Complete When” checklist.
- Do **NOT** add network/backends.

### Phase 2 (Cloud & Extras)
- Only start when explicitly told.
- Add API, sync, devotionals, community, monetization.

---

## 9. Deliverables Per Task

For each task:
1. Code changes (with tests if logic).
2. Short summary in PR/commit description.
3. Update TODO.md checkboxes if completed.
4. Note any deviation from guidelines.

---

## 10. Tooling & Scripts

- Provide CLI scripts under `/scripts`:
  - `usfm_to_usx`
  - `usx_to_sqlite/json`
- Log failures to `/logs/import.log`.

---

## 11. Performance Targets

- Reader scroll at 60fps on mid-tier Android.
- Search < 300ms for “common” queries (cached).
- Import parse time < reasonable (show progress).

---

Follow these rules; if unsure, refer back to README/TODO. If still unclear, ask.