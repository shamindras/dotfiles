// ============================================
// SURFINGKEYS CONFIGURATION
// Theme: Tomorrow Night (Foldex-style CSS variables)
// ============================================

// ============================================
// BASIC SETTINGS
// ============================================

// Show hints with minimal delay (0 might disable, so use 100ms)
settings.richHintsForKeystroke = 100;

// Show omnibar suggestions instantly (for og, ow, etc.)
settings.omnibarSuggestionTimeout = 0;

// Show mode status and available keys immediately
settings.startToShowEmoji = 0;

// Omnibar settings
settings.omnibarPosition = "middle";
settings.omnibarMaxResults = 10;

// ============================================
// TAB NAVIGATION - Vimium style
// ============================================

// Map h/l to previous/next tab (like Vimium)
api.map('h', 'E');  // E = previous tab
api.map('l', 'R');  // R = next tab

// Note: zh/zl repurposed for moving tabs to start/end (see below)
// Trade-off: Horizontal scrolling is sacrificed (shift+mousewheel still works)

// Map single < and > to move tabs left/right (like Vimium)
api.map('<', '<<');  // < = move tab left (single press)
api.map('>', '>>');  // > = move tab right (single press)

// ============================================
// CUSTOM NAVIGATION - Vimium style
// ============================================

// Link hints with Ctrl-F (safe on macOS where Cmd+F is native find)
api.map('<Ctrl-f>', 'f');

// Move tab to start/end - use zh/zl to preserve marks (m key)
api.mapkey('zh', '#3Move tab to beginning', function() {
    // Move tab left repeatedly until it's at position 0
    for (let i = 0; i < 100; i++) {
        api.Normal.feedkeys('<<');
    }
});
api.mapkey('zl', '#3Move tab to end', function() {
    // Move tab right repeatedly until it's at the end
    for (let i = 0; i < 100; i++) {
        api.Normal.feedkeys('>>');
    }
});

// First/last tab shortcuts (gh/gl)
api.map('gh', 'g0');  // First tab
api.map('gl', 'g$');  // Last tab

// Close current tab with zz
api.map('zz', 'x');

// ============================================
// YANK MARKDOWN LINK
// ============================================

// Yank current page as markdown link: [title](url)
api.mapkey('ym', '#7Copy as markdown link', function() {
    const title = document.title;
    const url = window.location.href;
    const markdown = `[${title}](${url})`;
    api.Clipboard.write(markdown);
    api.Front.showBanner(`Copied: ${markdown}`);
});

// ============================================
// VIM-STYLE SCROLLING (from Foldex)
// ============================================

// Scroll half page down/up (classic vim bindings)
api.mapkey("<Ctrl-d>", "Scroll half page down", () => {
    api.Normal.scroll("pageDown");
});
api.mapkey("<Ctrl-u>", "Scroll half page up", () => {
    api.Normal.scroll("pageUp");
});

// ============================================
// HISTORY NAVIGATION (uppercase H/L)
// ============================================

// History back/forward - no conflict with h/l tab navigation
api.map('H', 'S');   // History back
api.map('L', 'D');   // History forward

// ============================================
// PAGINATED CONTENT NAVIGATION
// ============================================

// Navigate to next/previous page in series (e.g., "Next →" / "← Previous")
api.map('K', '[[');  // Previous page
api.map('J', ']]');  // Next page

// ============================================
// OMNIBAR & BUFFER PICKER
// ============================================

// Buffer/tab picker (vim-style - moved to B to free up b for bookmarks)
api.map('B', 'T');   // B = buffer/tab picker (uppercase)
                     // b = bookmarks (keep default)

// Open omnibar in current tab (override/replace)
// This pairs with 't' (new tab) for a consistent uppercase/lowercase pattern
api.map('T', 'go');  // go = open URL in current tab
// Note: t (lowercase) = new tab (default), T (uppercase) = current tab

// ============================================
// NEW TAB - Open blank page where Surfingkeys works
// ============================================

// Override 'on' to open blank page instead of about:blank
api.unmap('on');
api.mapkey('on', 'Open new tab with blank page', function() {
    window.open('data:text/html,<html><head><title>New Tab</title></head><body style="background:#1D1F21;"></body></html>');
});

// ============================================
// LINK HINT CHARACTERS - Home row optimized
// ============================================

// Set hint characters to match Vimium (home row optimized)
api.Hints.setCharacters('sadfjklewcmpgh');

// ============================================
// SEARCH ENGINES - Complete replacement of defaults
// ============================================

// STEP 1: Remove all default Surfingkeys search engine mappings
api.removeSearchAlias('b');  // Remove Baidu
api.removeSearchAlias('d');  // Remove DuckDuckGo (default)
api.removeSearchAlias('g');  // Remove Google (will re-add with our settings)
api.removeSearchAlias('h');  // Remove GitHub
api.removeSearchAlias('s');  // Remove Stack Overflow
api.removeSearchAlias('w');  // Remove Bing
api.removeSearchAlias('y');  // Remove YouTube (will re-add)

// STEP 2: Add our custom search engines
api.addSearchAlias('b', 'imdb', 'http://www.imdb.com/find?s=all&q=');
api.addSearchAlias('g', 'google', 'https://www.google.com/search?q=');
api.addSearchAlias('k', 'duckduckgo', 'https://duckduckgo.com/?q=');
api.addSearchAlias('l', 'libgen', 'https://libgen.li/index.php?req=');
api.addSearchAlias('m', 'google-maps', 'https://www.google.com/maps?q=');
api.addSearchAlias('n', 'annas-archive', 'https://annas-archive.li/search?q=');
api.addSearchAlias('w', 'wikipedia', 'https://www.wikipedia.org/w/index.php?title=Special:Search&search=');
api.addSearchAlias('y', 'youtube', 'https://www.youtube.com/results?search_query=');
api.addSearchAlias('z', 'amazon-au', 'https://www.amazon.com.au/s/?field-keywords=');

// STEP 3: Add Ctrl-based shortcuts for quick access (matches Vimium)
api.mapkey('<Ctrl-b>', 'Search IMDB', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "b"});
});
api.mapkey('<Ctrl-g>', 'Search Google', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "g"});
});
api.mapkey('<Ctrl-k>', 'Search DuckDuckGo', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "k"});
});
api.mapkey('<Ctrl-l>', 'Search Libgen', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "l"});
});
api.mapkey('<Ctrl-m>', 'Search Google Maps', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "m"});
});
api.mapkey('<Ctrl-n>', 'Search Anna\'s Archive', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "n"});
});
api.mapkey('<Ctrl-w>', 'Search Wikipedia', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "w"});
});
api.mapkey('<Ctrl-y>', 'Search YouTube', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "y"});
});
api.mapkey('<Ctrl-z>', 'Search Amazon AU', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "z"});
});

// ============================================
// SITE EXCLUSIONS - Port from Vimium
// ============================================

// COMPLETELY DISABLE Surfingkeys on these sites
settings.blocklistPattern = /localhost:888[89]|localhost:8890|multiplexer-prod\.datacamp\.com|app\.gather\.town|type-fu\.com|app\.coderpad\.io|games\.usatoday\.com|vimaroo\.vercel\.app|static\.licdn\.com|cocalc\.com\/projects|docs\.google\.com\/(document|presentation)/i;

// ============================================
// PASSTHROUGH HELPER FUNCTION
// ============================================

// Helper: Pass a key through to the page's native handlers
function passKeyToPage(key) {
    // Dispatch keyboard events that sites can catch
    ['keydown', 'keypress', 'keyup'].forEach(eventType => {
        document.dispatchEvent(new KeyboardEvent(eventType, {
            key: key,
            code: `Key${key.toUpperCase()}`,
            keyCode: key.charCodeAt(0),
            which: key.charCodeAt(0),
            bubbles: true,
            cancelable: true
        }));
    });
}

// ============================================
// VIDEO SITES - Passthrough for f, m, t
// ============================================

// YouTube - f (fullscreen), m (mute), t (theater mode)
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /youtube\.com\/watch/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /youtube\.com\/watch/});
api.mapkey('t', '#0Theater mode', () => passKeyToPage('t'), {domain: /youtube\.com\/watch/});

// YouTube homepage - just m
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /youtube\.com/});

// YouTube search (/) - focus search input
api.mapkey('/', '#0Focus YouTube search', function() {
    const searchInput = document.querySelector('input#search');
    if (searchInput) searchInput.focus();
}, {domain: /youtube\.com/i});

// Netflix
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /netflix\.com\/watch/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /netflix\.com\/watch/});

// Amazon Video
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /amazon\.com\/gp\/video/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /amazon\.com\/gp\/video/});

// Prime Video
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /primevideo\.com/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /primevideo\.com/});

// Crunchyroll
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /crunchyroll\.com/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /crunchyroll\.com\/watch/});
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /static\.crunchyroll\.com/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /static\.crunchyroll\.com/});

// HiAnime
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /hianime\.to/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /hianime\.to/});

// AniCrush
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /anicrush\.to/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /anicrush\.to/});

// Bilibili
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /bilibili\.com/});

// Peacock
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /peacocktv\.com/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /peacocktv\.com/});

// Paramount+
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /paramountplus\.com/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /paramountplus\.com/});

// Dailymotion
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /dailymotion\.com/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /dailymotion\.com/});

// iView ABC
api.mapkey('f', '#0Fullscreen', () => passKeyToPage('f'), {domain: /iview\.abc\.net\.au/});
api.mapkey('m', '#0Mute', () => passKeyToPage('m'), {domain: /iview\.abc\.net\.au/});
api.mapkey('/', '#0Focus iView search', function() {
    const searchInput = document.querySelector('input[type="search"]') ||
                       document.querySelector('input[placeholder*="Search"]');
    if (searchInput) searchInput.focus();
}, {domain: /iview\.abc\.net\.au/i});

// ============================================
// GOOGLE SERVICES - Passthrough
// ============================================

// Google Drive - / (search)
api.mapkey('/', '#0Focus Drive search', function() {
    const searchInput = document.querySelector('input[aria-label*="Search"]') ||
                       document.querySelector('input[placeholder*="Search"]');
    if (searchInput) searchInput.focus();
}, {domain: /drive\.google\.com/i});

// Google Docs - p (print), m, / (find)
api.mapkey('p', '#0Print', () => passKeyToPage('p'), {domain: /docs\.google\.com/});
api.mapkey('m', '#0Passthrough m', () => passKeyToPage('m'), {domain: /docs\.google\.com/});
api.mapkey('/', '#0Open Docs find', function() {
    document.dispatchEvent(new KeyboardEvent('keydown', {
        key: 'f',
        code: 'KeyF',
        ctrlKey: true,
        bubbles: true
    }));
}, {domain: /docs\.google\.com/i});

// Google Calendar - d (day), m (month)
api.mapkey('d', '#0Day view', () => passKeyToPage('d'), {domain: /calendar\.google\.com/});
api.mapkey('m', '#0Month view', () => passKeyToPage('m'), {domain: /calendar\.google\.com/});

// Gmail - Pass through ALL Gmail shortcuts
const gmailKeys = ['a', 'b', 'd', 'e', 'f', 'g', 'i', 'j', 'k', 'l', 'm', 'r', 'v', 'x', 'X'];
gmailKeys.forEach(key => {
    api.mapkey(key, `#0Gmail shortcut: ${key}`, () => passKeyToPage(key), {domain: /mail\.google\.com/});
});

// Gmail search (/)
api.mapkey('/', '#0Focus Gmail search', function() {
    const searchInput = document.querySelector('input[aria-label*="Search"]') ||
                       document.querySelector('input[name="q"]');
    if (searchInput) searchInput.focus();
}, {domain: /mail\.google\.com/i});

// ============================================
// OTHER SITES - Passthrough
// ============================================

// DuckDuckGo - / (search)
api.mapkey('/', '#0Focus DuckDuckGo search', function() {
    const searchInput = document.querySelector('input#search_form_input') ||
                       document.querySelector('input[name="q"]') ||
                       document.querySelector('input[type="search"]');
    if (searchInput) searchInput.focus();
}, {domain: /duckduckgo\.com/i});

// Container Store - p
api.mapkey('p', '#0Passthrough p', () => passKeyToPage('p'), {domain: /containerstore\.com/});

// Walmart - b, m, p
api.mapkey('b', '#0Passthrough b', () => passKeyToPage('b'), {domain: /walmart\.wd5\.myworkdayjobs\.com/});
api.mapkey('m', '#0Passthrough m', () => passKeyToPage('m'), {domain: /walmart\.wd5\.myworkdayjobs\.com/});
api.mapkey('p', '#0Passthrough p', () => passKeyToPage('p'), {domain: /walmart\.wd5\.myworkdayjobs\.com/});

// Localhost:2718 - a, m
api.mapkey('a', '#0Passthrough a', () => passKeyToPage('a'), {domain: /localhost:2718/});
api.mapkey('m', '#0Passthrough m', () => passKeyToPage('m'), {domain: /localhost:2718/});

// ============================================
// THEME: TOMORROW NIGHT (Foldex-style)
// ============================================

// Hint styling
api.Hints.style('border: solid 2px #373B41; color:#52C196; background: initial; background-color: #1D1F21;');
api.Hints.style("border: solid 2px #373B41 !important; padding: 1px !important; color: #C5C8C6 !important; background: #1D1F21 !important;", "text");
api.Visual.style('marks', 'background-color: #52C19699;');
api.Visual.style('cursor', 'background-color: #81A2BE;');

// Main theme
settings.theme = `
/* ===== TOMORROW NIGHT THEME ===== */
/* Based on Foldex's surfingkeys-config structure */

/* Edit these variables for easy color customization */
:root {
  /* Font */
  --font: 'Menlo', 'Monaco', 'Source Code Pro', monospace;
  --font-size: 12pt;
  --font-weight: normal;

  /* Tomorrow Night Colors */
  --fg: #C5C8C6;
  --bg: #282A2E;
  --bg-dark: #1D1F21;
  --border: #373b41;
  --main-fg: #81A2BE;
  --accent-fg: #52C196;
  --info-fg: #AC7BBA;
  --select: #585858;
}

/* ---------- Generic ---------- */
.sk_theme {
  background: var(--bg) !important;
  color: var(--fg) !important;
  background-color: var(--bg) !important;
  border-color: var(--border);
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}

input {
  font-family: var(--font);
  font-weight: var(--font-weight);
}

.sk_theme tbody {
  color: var(--fg) !important;
}

.sk_theme input {
  color: var(--fg) !important;
  background: var(--bg) !important;
}

/* Hints */
#sk_hints .begin {
  color: var(--accent-fg) !important;
}

#sk_tabs .sk_tab {
  background: var(--bg-dark) !important;
  border: 1px solid var(--border);
}

#sk_tabs .sk_tab_title {
  color: var(--fg) !important;
}

#sk_tabs .sk_tab_url {
  color: var(--main-fg) !important;
}

#sk_tabs .sk_tab_hint {
  background: var(--bg) !important;
  border: 1px solid var(--border);
  color: var(--accent-fg) !important;
}

.sk_theme #sk_frame {
  background: var(--bg) !important;
  opacity: 0.2;
  color: var(--accent-fg) !important;
}

/* ---------- Omnibar ---------- */
#sk_omnibar {
  width: 80%;
  max-width: 1000px;
  background: var(--bg) !important;
  border: 2px solid var(--border);
}

.sk_theme .title {
  color: var(--accent-fg) !important;
}

.sk_theme .url {
  color: var(--main-fg) !important;
}

.sk_theme .annotation {
  color: var(--accent-fg) !important;
}

.sk_theme .omnibar_highlight {
  color: var(--accent-fg) !important;
}

.sk_theme .omnibar_timestamp {
  color: var(--info-fg) !important;
}

.sk_theme .omnibar_visitcount {
  color: var(--accent-fg) !important;
}

/* CRITICAL FIX: Force dark backgrounds on all list items */
.sk_theme #sk_omnibarSearchResult ul li {
  background: var(--bg-dark) !important;
}

.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
  background: var(--bg-dark) !important;
}

.sk_theme #sk_omnibarSearchResult ul li:nth-child(even) {
  background: var(--bg-dark) !important;
}

/* Explicit overrides for each position to defeat default styles */
.sk_theme #sk_omnibarSearchResult ul li:nth-child(1) { background: var(--bg-dark) !important; }
.sk_theme #sk_omnibarSearchResult ul li:nth-child(2) { background: var(--bg-dark) !important; }
.sk_theme #sk_omnibarSearchResult ul li:nth-child(3) { background: var(--bg-dark) !important; }
.sk_theme #sk_omnibarSearchResult ul li:nth-child(4) { background: var(--bg-dark) !important; }
.sk_theme #sk_omnibarSearchResult ul li:nth-child(5) { background: var(--bg-dark) !important; }
.sk_theme #sk_omnibarSearchResult ul li:nth-child(6) { background: var(--bg-dark) !important; }
.sk_theme #sk_omnibarSearchResult ul li:nth-child(7) { background: var(--bg-dark) !important; }
.sk_theme #sk_omnibarSearchResult ul li:nth-child(8) { background: var(--bg-dark) !important; }
.sk_theme #sk_omnibarSearchResult ul li:nth-child(9) { background: var(--bg-dark) !important; }
.sk_theme #sk_omnibarSearchResult ul li:nth-child(10) { background: var(--bg-dark) !important; }

.sk_theme #sk_omnibarSearchResult ul li.focused {
  background: var(--select) !important;
}

.sk_theme #sk_omnibarSearchArea {
  border-top-color: var(--border);
  border-bottom-color: var(--border);
  background: var(--bg) !important;
}

.sk_theme #sk_omnibarSearchArea input,
.sk_theme #sk_omnibarSearchArea span {
  font-size: var(--font-size);
  color: var(--fg) !important;
  background: var(--bg) !important;
}

.sk_theme .separator {
  color: var(--accent-fg) !important;
}

/* ---------- Popup Notification Banner ---------- */
#sk_banner {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
  background: var(--bg) !important;
  border-color: var(--border);
  color: var(--fg) !important;
  opacity: 0.9;
}

/* ---------- Popup Keys ---------- */
#sk_keystroke {
  background-color: var(--bg) !important;
  color: var(--fg) !important;
  border: 2px solid var(--border);
  font-size: 16pt;
  opacity: 1 !important;
  display: block !important;
  visibility: visible !important;
  z-index: 2147483647 !important;
  padding: 10px;
}

#sk_keystroke kbd {
  background: var(--bg-dark) !important;
  color: var(--accent-fg) !important;
  border: 1px solid var(--border);
  padding: 5px 9px;
  margin: 3px;
  font-family: var(--font);
  font-size: 17pt;
  font-weight: bold;
}

.sk_theme kbd .candidates {
  color: var(--info-fg) !important;
  font-size: 16pt;
}

.sk_theme span.annotation {
  color: var(--accent-fg) !important;
  font-size: 16pt;
}

/* ---------- Popup Translation Bubble ---------- */
#sk_bubble {
  background-color: var(--bg) !important;
  color: var(--fg) !important;
  border-color: var(--border) !important;
}

#sk_bubble * {
  color: var(--fg) !important;
}

#sk_bubble div.sk_arrow div:nth-of-type(1) {
  border-top-color: var(--border) !important;
  border-bottom-color: var(--border) !important;
}

#sk_bubble div.sk_arrow div:nth-of-type(2) {
  border-top-color: var(--bg) !important;
  border-bottom-color: var(--bg) !important;
}

/* ---------- Search ---------- */
#sk_status,
#sk_find {
  font-size: var(--font-size);
  border-color: var(--border);
  background: var(--bg) !important;
  color: var(--fg) !important;
}

#sk_find input {
  background: var(--bg) !important;
  color: var(--fg) !important;
}

.sk_theme kbd {
  background: var(--bg-dark) !important;
  border-color: var(--border);
  box-shadow: none;
  color: var(--fg) !important;
}

.sk_theme .feature_name span {
  color: var(--main-fg) !important;
}

/* ---------- ACE Editor ---------- */
#sk_editor {
  background: var(--bg-dark) !important;
  height: 50% !important;
}

.ace_dialog-bottom {
  border-top: 1px solid var(--bg) !important;
}

.ace-chrome .ace_print-margin,
.ace_gutter,
.ace_gutter-cell,
.ace_dialog {
  background: var(--bg) !important;
}

.ace-chrome {
  color: var(--fg) !important;
}

.ace_gutter,
.ace_dialog {
  color: var(--fg) !important;
}

.ace_cursor {
  color: var(--fg) !important;
}

.normal-mode .ace_cursor {
  background-color: var(--fg) !important;
  border: var(--fg) !important;
  opacity: 0.7 !important;
}

.ace_marker-layer .ace_selection {
  background: var(--select) !important;
}

.ace_editor,
.ace_dialog span,
.ace_dialog input {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}
`;
