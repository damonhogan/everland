Everland React port

Run the asset generator, then start the React dev server and tests.

Generate assets (from authoritative `bbs/` folder):

```bash
node tools/convert_assets.js
```

Install and run dev server:

```bash
cd react
npm ci
npm run dev
```

Build for production:

```bash
cd react
npm ci
npm run build
```

Run tests:

```bash
cd react
npm test
```

Notes

- Saves, events and backups are stored in `localStorage` under keys like `everland_save`, `everland_events`, and `everland_save_backup_<ts>`.
- Use the in-app `Restore Backups` panel to preview/restore/undo backups.
- NPC shop, quests and other assets are generated into `react/public/bbs` by the asset generator.
- If you change `bbs/` sources, re-run the asset generator to refresh JSON assets.
 - `react/tools/convert_assets.js` generates `npcs_full.json`. Each NPC object now includes generator defaults: `restockDefaultQty` (number), `patrolTemplate` (array of location labels) and `defaultPatrolIntervalMs` (ms). These are applied by the app as sensible defaults when initializing runtime `npcState`.
 - The Auto-export toggle for exporting `npcs-edited.json` is now persisted centrally in the runtime `npcState` under `_app.autoExport` (set via the NPC panel). This allows team-wide tooling to read the setting from the exported edits merge.
 - CI-friendly demo build: run `npm run build:zip` in `react/` to build and create a ZIP under `react/`.
 - To make browser-exported edits consumable in CI/tooling, place an array of edited NPC objects into `react/npcs_edits_input.json` and run `node scripts/consume_edited_export.js` — this writes `react/public/bbs/npcs-edited.json` for tooling to pick up.
 - The scheduler now exposes a testable tick function `runNpcSchedulerTick(npcs, state, addToast, intervalMs)` in `react/src/lib/npcScheduler.ts` for deterministic testing.

If you want me to wire CI, build artifacts, or produce a demo bundle next, tell me which target (GitHub Pages, Netlify, or a static ZIP).
