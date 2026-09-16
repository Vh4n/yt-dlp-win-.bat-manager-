# YT-DLP Manager

A simple menu-driven Windows batch script for downloading video and audio with `yt-dlp`.

## Folder Structure

```
YourFolder/
├── yt-dlp-downloader.bat      <-- the script itself
├── bin/
│   ├── yt-dlp.exe
│   ├── ffmpeg.exe
│   ├── ffprobe.exe
│   ├── ffplay.exe
│   └── deno.exe
└── Downloads/                 <-- created automatically, downloads go here
```

**The `.bat` file goes outside the `bin` folder, one level up.** It uses its own
location to find `bin` and `Downloads` next to it, so moving the `.bat` file
without the `bin` folder (or vice versa) will break it.

**All `.exe` files go inside `bin`:**

| File | Required for |
|---|---|
| `yt-dlp.exe` | Everything — the script won't run without this |
| `ffmpeg.exe` | MP4/MP3 conversion, merging separate video+audio streams, trimming to a time range |
| `ffprobe.exe` | Used internally by yt-dlp/ffmpeg for media inspection |
| `ffplay.exe` | Not required by this script, but yt-dlp expects it alongside ffmpeg/ffprobe in the same folder |
| `deno.exe` | Used by yt-dlp for some site extractors that rely on JavaScript execution |

You don't strictly need every file to use every feature — for example, you can
download a single pre-merged video file without ffmpeg — but keeping the full
set in `bin` avoids random failures on videos or sites that need one of them.

## Setup

1. Download `yt-dlp.exe`, `ffmpeg.exe`, `ffprobe.exe`, `ffplay.exe`, and
   `deno.exe`.
2. Put all five files inside a folder named `bin`.
3. Put the `bin` folder in the same folder as `yt-dlp-downloader.bat`.
4. Run `yt-dlp-downloader.bat`.

A `Downloads` folder will be created automatically next to the script the
first time it runs, and all downloaded files are saved there.

## Usage

Run the script and follow the on-screen menu:

- **Download Video** — choose a resolution, optionally trim to a start/end
  time, and optionally convert/merge to MP4.
- **Download Audio** — choose a bitrate and optionally convert to MP3.

If `ffmpeg.exe` is missing, any option that needs it (MP4/MP3 conversion,
merging, trimming) will show an error and let you go back and choose an
option that doesn't require it instead.

## Credits

This script is just a front-end. All the actual downloading is done by
**yt-dlp**: https://github.com/yt-dlp/yt-dlp

Get `yt-dlp.exe` from their releases page, and see their repo for
documentation, supported sites, and updates.
