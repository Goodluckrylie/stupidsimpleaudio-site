# Audio demos

Drop your rendered audio files here. The website looks for these exact
filenames — the play buttons on the page won't make any noise until they're
in place. Missing files are handled silently (no console errors visible to
visitors), so you can ship the page now and add demos as you render them.

## File list (23 total)

```
audio/
├── dry.mp3        — your source/reference loop (plays from the bar above the grid)
├── delay.mp3      — dry processed through Stupid Simple Delay
├── reverb.mp3
├── wobbler.mp3
├── filter.mp3
├── panner.mp3
├── wide.mp3
├── double.mp3
├── voice.mp3
├── warmer.mp3
├── tone.mp3
├── deesser.mp3
├── squeeze.mp3
├── brick.mp3
├── crunch.mp3
├── smasher.mp3
├── heat.mp3
├── stutter.mp3
├── tapestop.mp3
├── freeze.mp3
├── reverse.mp3
├── glitch.mp3
└── wow.mp3
```

## Recommended workflow in Ableton

1. **Pick a versatile loop** for the dry source — 12-20 seconds. Drum-and-bass
   or a mid-tempo loop with vocals + drums + chords works well because every
   plugin in the suite has something audible to do with it.
2. **Render `dry.mp3` first.** Export at 44.1kHz / 192kbps MP3 (or 256 if you
   want extra fidelity — file size still tiny).
3. **For each plugin:** drop it on the loop's track, dial in a *flattering
   default* (not the loudest preset — pick the setting a buyer would
   immediately like), bounce.
4. **Drag all 23 files into this folder** with the exact names above.

## Format notes

- **MP3** is the recommended format — universal browser support, ~200KB per
  15-second clip at 192kbps.
- The player will also accept any format the browser supports (MP3, WAV, M4A,
  Ogg). If you swap, update the file extension in `audio-player.js`
  (the line `audio.src = \`audio/${name}.mp3\``).
- All clips should be **the same length and start at the same point** as
  `dry.mp3` so visitors can A/B by clicking around without losing the beat.
  Render with the source loop's exact start/end markers.
- Aim for ~ -6 dBFS peak so the loudest plugin (Smasher, Crunch) doesn't
  blow people's ears off.

## Quick QA before you ship

After dropping the files in:

1. Preview locally (`python3 -m http.server 8000` from the `website/` folder)
2. Click each play button on the page — should hear that plugin's sample
3. Click a different plugin while one is playing — first should stop, new
   should start
4. Refresh the page — sound should NOT auto-play (we don't pre-load)
