// ===========================================================================
// audio-player.js — shared <audio> instance for the dry sample + all 22
// plugin demos. Click any play button:
//   - if nothing is playing, plays the matching audio/<name>.mp3
//   - if THIS button's clip is playing, pauses it
//   - if a DIFFERENT button's clip is playing, stops it and plays this one
//
// Gracefully no-ops when an audio file 404s (the user can ship before all
// demos are rendered).
// ===========================================================================

(function () {
  'use strict';

  // Bump this version whenever you regenerate audio files. Forces the browser
  // to bypass its cache of the previous mp3s — otherwise Chrome/Safari will
  // happily keep serving the old audio after you re-render.
  const AUDIO_VERSION = 8;

  // Sanity log so we can confirm in DevTools console which version of the JS
  // is running. If you see `stupid-simple-audio v=3` here, your browser is
  // serving a stale audio-player.js — hard-refresh.
  console.log("stupid-simple-audio audio-player.js loaded · v=" + AUDIO_VERSION);

  const audio = new Audio();
  audio.preload = 'none';
  let currentBtn = null;

  function setPlaying(btn) {
    if (currentBtn && currentBtn !== btn) currentBtn.classList.remove('playing');
    currentBtn = btn;
    if (btn) btn.classList.add('playing');
  }

  function clearPlaying() {
    if (currentBtn) currentBtn.classList.remove('playing');
    currentBtn = null;
  }

  function playClip(name, btn) {
    // Toggle off if this button is the current one and audio is playing.
    if (currentBtn === btn && !audio.paused) {
      audio.pause();
      return;
    }
    // Use Date.now() so every play request is a unique URL — bypasses any
    // possible browser audio caching, no matter how aggressive.
    audio.src = `audio/${name}.mp3?v=${AUDIO_VERSION}&t=${Date.now()}`;
    const playPromise = audio.play();
    setPlaying(btn);
    if (playPromise && playPromise.catch) {
      // Browser blocked autoplay, or the file 404'd, etc. Quietly clear state.
      playPromise.catch(() => clearPlaying());
    }
  }

  audio.addEventListener('ended', clearPlaying);
  audio.addEventListener('pause', () => {
    // Only clear when actually stopped (currentTime resets to 0); ignore mid-stream pauses
    // that fire briefly when switching sources.
    if (audio.currentTime === 0 || audio.ended) clearPlaying();
  });
  audio.addEventListener('error', clearPlaying);

  document.addEventListener('click', (e) => {
    const btn = e.target.closest('.play-btn');
    if (!btn) return;
    // Prevent the parent <a class="card"> link from navigating.
    e.preventDefault();
    e.stopPropagation();
    const name = btn.dataset.audio;
    if (name) playClip(name, btn);
  });

  // Keyboard support: space/enter on a focused play-btn triggers click — the
  // browser already handles this on <button> elements, no extra code needed.
})();
