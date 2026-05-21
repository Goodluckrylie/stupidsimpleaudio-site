# Stupid Simple — website

Single-page static site for **stupidsimpleaudio.com**. Pure HTML + CSS, no
build step, no JS framework. Drop it on any static host and it works.

## Files

```
website/
├── index.html       — the page (3 sections: hero, plugin grid, footer)
├── style.css        — brand-matched styling
├── smiley.svg       — logo (copied from shared/resources/)
├── LICENSE.txt      — EULA (linked from footer)
└── README.md        — you are here
```

## Preview locally

```bash
cd website
python3 -m http.server 8000
# open http://localhost:8000
```

Or just open `index.html` in your browser — no server needed.

## Pricing model

- **$5 per plugin** — each plugin card is a buy button that links to that plugin's own Gumroad product
- **$40 for the bundle** — the big hero button + the "Or grab all 22 for $40" nudge under the grid

## Before going live — fill in the 23 Gumroad URLs

The site has **23 placeholder strings** that need real Gumroad product URLs.
Search and replace each one in `index.html`:

| Placeholder | What it points to |
|---|---|
| `BUY_BUNDLE_URL` | Bundle ($40) — appears **twice** (hero button + bundle nudge) |
| `BUY_DELAY_URL` | Delay ($5) |
| `BUY_REVERB_URL` | Reverb ($5) |
| `BUY_WOBBLER_URL` | Wobbler ($5) |
| `BUY_FILTER_URL` | Filter ($5) |
| `BUY_PANNER_URL` | Panner ($5) |
| `BUY_WIDE_URL` | Wide ($5) |
| `BUY_DOUBLE_URL` | Double ($5) |
| `BUY_VOICE_URL` | Voice ($5) |
| `BUY_WARMER_URL` | Warmer ($5) |
| `BUY_TONE_URL` | Tone ($5) |
| `BUY_DEESSER_URL` | De-Esser ($5) |
| `BUY_SQUEEZE_URL` | Squeeze ($5) |
| `BUY_BRICK_URL` | Brick ($5) |
| `BUY_CRUNCH_URL` | Crunch ($5) |
| `BUY_SMASHER_URL` | Smasher ($5) |
| `BUY_HEAT_URL` | Heat ($5) |
| `BUY_STUTTER_URL` | Stutter ($5) |
| `BUY_TAPESTOP_URL` | Tape Stop ($5) |
| `BUY_FREEZE_URL` | Freeze ($5) |
| `BUY_REVERSE_URL` | Reverse ($5) |
| `BUY_GLITCH_URL` | Glitch ($5) |
| `BUY_WOW_URL` | Wow ($5) |

**Tip:** set up the bundle product in Gumroad first, fill in `BUY_BUNDLE_URL`,
deploy the site. The individual product links can launch later — until they
exist, those cards' hover state still works fine; the link just won't go
anywhere useful until you set them up.

### Quick way to mass-edit

When you have all 23 URLs, dump them into a script like:

```bash
sed -i '' \
  -e 's|BUY_BUNDLE_URL|https://gumroad.com/l/...|g' \
  -e 's|BUY_DELAY_URL|https://gumroad.com/l/...|g' \
  -e 's|BUY_REVERB_URL|https://gumroad.com/l/...|g' \
  ...etc... \
  index.html
```

## Hosting

### Recommended: Cloudflare Pages (free, fast, custom domains free)

1. Create a free GitHub repo (e.g. `stupidsimple-site`)
2. Commit and push the `website/` folder contents *to the repo root*
3. In Cloudflare: **Pages → Create project → Connect to GitHub**
4. Build settings: framework = `None`, build command = *blank*, output = `/`
5. Custom domain → `stupidsimpleaudio.com` → follow Cloudflare's DNS steps
6. Done. Pushes to `main` auto-deploy.

### Alternatives

- **Vercel** — same flow, also free.
- **Netlify** — same flow, free tier is fine.
- **GitHub Pages** — free, but custom domain SSL takes longer to provision than Cloudflare.

## Design notes

- Color palette + `smiley.svg` are pulled directly from the plugin code
  (`shared/include/SSColors.h`, `shared/resources/`). Re-copy if the plugin
  brand ever tweaks.
- Font stack is Caveat + Patrick Hand (Google Fonts) — closest free
  approximation of Marker Felt.
- Every plugin card is itself an `<a>` link. The price `$5` lives in the
  bottom-right of each card. Hovering flips the card to yellow.

## Editing checklist

- Add or remove a plugin → add/remove a `.card` block in `index.html` AND
  update the number "22" everywhere (search for `22` and `twenty-two`).
- Change pricing → search for `$5` and `$40` in `index.html`. Currently 1
  occurrence each in the hero/nudge, and `$5` × 22 on cards.
- Change support email → search for `goodluck.rylie@gmail.com` (footer +
  `LICENSE.txt`).
