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

If you want me to wire CI, build artifacts, or produce a demo bundle next, tell me which target (GitHub Pages, Netlify, or a static ZIP).
