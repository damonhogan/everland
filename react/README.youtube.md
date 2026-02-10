YouTube Ingest — Everland

This folder contains simple scaffolding to index and ingest videos from a YouTube channel.

Requirements
- `yt-dlp` on PATH (for downloads)
- `ffmpeg` on PATH (yt-dlp uses it for audio extraction)
- Optional: `whisper` CLI for local transcription
- YouTube Data API key for metadata: set `YT_API_KEY` environment variable

Indexing and ingest example

1. List and download recent uploads (metadata, thumbnails, audio):

```bash
YT_API_KEY=your_key_here node react/tools/youtube_ingest.js UCMXCPPNbXi8qchjzxUUaI4A
```

2. Transcribe a downloaded audio file (if `whisper` is installed):

```bash
node react/tools/transcribe.js react/public/music/<videoid>.mp3
```

Notes
- The scripts are scaffolds: replace or extend with cloud transcription or a cartoonization service if needed.
- All ingested files are stored under `react/public/images` and `react/public/music`, and an index is written to `react/public/bbs/youtube_index.json`.
