// ===========================================================================
// plugin-modal.js — opens a detail view when a plugin card is clicked.
//
// Pulls everything it needs from the card itself: plugin name from
// .card-name, description from .card-desc, audio name from the .play-btn
// inside the card, Gumroad URL from the card's href.
//
// Falls back gracefully when the screenshot is missing — shows a "coming
// soon" placeholder instead of a broken image.
// ===========================================================================

(function () {
  'use strict';

  const modal      = document.getElementById('plugin-modal');
  if (!modal) return;

  const titleEl    = modal.querySelector('.modal-title');
  const descEl     = modal.querySelector('.modal-desc');
  const imgEl      = modal.querySelector('#modal-img');
  const fallbackEl = modal.querySelector('.modal-screenshot-fallback');
  const playBtns   = modal.querySelectorAll('.modal-play-btn');   // 3 buttons: vocal/drums/piano
  const buyBtn     = modal.querySelector('#modal-buy');

  function open(card) {
    const name       = card.querySelector('.card-name').textContent.trim();
    const desc       = card.querySelector('.card-desc').textContent.trim();
    // The card's play button has data-audio="<plugin>-<source>" (e.g. "delay-vocal").
    // We strip the source suffix to get the plugin base for screenshot + 3-source buttons.
    const cardAudio  = card.querySelector('.play-btn').dataset.audio;
    const pluginKey  = cardAudio.replace(/-(vocal|drums|piano)$/, '');
    const buyUrl     = card.getAttribute('href');

    titleEl.textContent    = "Stupid Simple " + name;
    descEl.textContent     = desc;
    buyBtn.href            = buyUrl;
    buyBtn.textContent     = `Buy ${name} — $5`;

    // Wire up each of the 3 source-specific play buttons with the right audio file.
    playBtns.forEach(btn => {
      const source = btn.dataset.source;  // "vocal" | "drums" | "piano"
      btn.dataset.audio = `${pluginKey}-${source}`;
      btn.setAttribute('aria-label', `Play ${name} on ${source}`);
    });

    // Simplest possible image load: always show img, hide fallback. If the
    // image 404s, the browser shows its broken-image icon (visible debug).
    const imgUrl = `previews/${pluginKey}.png?t=${Date.now()}`;
    console.log("[modal] setting img src:", imgUrl);
    imgEl.src = imgUrl;
    imgEl.alt = `Screenshot of Stupid Simple ${name}`;
    imgEl.style.display = 'block';
    fallbackEl.style.display = 'none';

    modal.hidden = false;
    requestAnimationFrame(() => modal.classList.add('open'));
    document.body.style.overflow = 'hidden';
  }

  function close() {
    modal.classList.remove('open');
    document.body.style.overflow = '';
    // Stop any audio that's playing from a modal play button.
    playBtns.forEach(btn => {
      if (btn.classList.contains('playing')) btn.click();
    });
    setTimeout(() => { modal.hidden = true; }, 200);
  }

  // Card click → open modal. We intercept the card link (which would
  // otherwise navigate directly to Gumroad), unless the click came from a
  // play button inside the card (that one's already handled by audio-player.js).
  document.addEventListener('click', (e) => {
    // Modal close handlers (backdrop click, close button)
    if (e.target.closest('[data-modal-close]')) {
      e.preventDefault();
      close();
      return;
    }

    // Play button click inside a card: let audio-player.js handle it, don't open modal.
    if (e.target.closest('.play-btn')) return;

    // Otherwise: was the click on a plugin card?
    const card = e.target.closest('.card');
    if (!card) return;

    e.preventDefault();
    e.stopPropagation();
    open(card);
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !modal.hidden) close();
  });

  console.log('stupid-simple-audio plugin-modal.js loaded');
})();
