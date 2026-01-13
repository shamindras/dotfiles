// ============================================
// SURFINGKEYS CONFIGURATION
// Ported from Vimium with custom enhancements
// Last updated: 2026-01-11
// ============================================

// ============================================
// BASIC SETTINGS
// ============================================

// Show hints instantly (no delay)
settings.richHintsForKeystroke = 0;

// Omnibar settings
settings.omnibarPosition = "middle";
settings.omnibarMaxResults = 10;

// ============================================
// TAB NAVIGATION - Vimium style
// ============================================

// Map h/l to previous/next tab (like Vimium)
api.map('h', 'E');  // E = previous tab
api.map('l', 'R');  // R = next tab

// Restore horizontal scrolling on zh/zl
api.map('zh', 'h');  // zh = scroll left
api.map('zl', 'l');  // zl = scroll right

// Map single < and > to move tabs left/right (like Vimium)
api.map('<', '<<');  // < = move tab left (single press)
api.map('>', '>>');  // > = move tab right (single press)

// ============================================
// CUSTOM NAVIGATION - Vimium style
// ============================================

// Link hints with Ctrl-F (safe on macOS where Cmd+F is native find)
api.map('<Ctrl-f>', 'f');

// Move tab to start/end - use mh/ml to avoid search leader conflict
api.mapkey('mh', 'Move tab to beginning', function() {
    api.RUNTIME('moveTab', {position: 0});
});
api.mapkey('ml', 'Move tab to end', function() {
    api.RUNTIME('moveTab', {position: -1});
});

// First/last tab shortcuts (gh/gl)
api.map('gh', 'g0');  // First tab
api.map('gl', 'g$');  // Last tab

// Close current tab with zz
api.map('zz', 'x');

// ============================================
// NEW TAB - Open blank page where Surfingkeys works
// ============================================

// Override 'on' to open blank page instead of about:blank
api.unmap('on');
api.mapkey('on', 'Open new tab with blank page', function() {
    window.open('data:text/html,<html><head><title>New Tab</title></head><body style="background:#24273a;"></body></html>');
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

// PARTIALLY DISABLE - Unmap specific keys on video/streaming sites
// YouTube
api.unmap('m', /youtube\.com\/watch/);
api.unmap('t', /youtube\.com\/watch/);
api.unmap('/', /youtube\.com\/watch/);
api.unmap('f', /youtube\.com\/watch/);
api.unmap('/', /youtube\.com/);
api.unmap('m', /youtube\.com/);

// Netflix & Amazon Video
api.unmap('f', /netflix\.com\/watch/);
api.unmap('m', /netflix\.com\/watch/);
api.unmap('f', /amazon\.com\/gp\/video/);
api.unmap('m', /amazon\.com\/gp\/video/);
api.unmap('f', /primevideo\.com/);
api.unmap('m', /primevideo\.com/);

// Crunchyroll
api.unmap('f', /crunchyroll\.com$/);
api.unmap('f', /crunchyroll\.com\/watch/);
api.unmap('m', /crunchyroll\.com\/watch/);
api.unmap('f', /static\.crunchyroll\.com/);
api.unmap('m', /static\.crunchyroll\.com/);

// Other anime/video sites
api.unmap('f', /hianime\.to/);
api.unmap('m', /hianime\.to/);
api.unmap('f', /anicrush\.to/);
api.unmap('m', /anicrush\.to/);
api.unmap('f', /bilibili\.com/);
api.unmap('f', /peacocktv\.com/);
api.unmap('m', /peacocktv\.com/);
api.unmap('f', /paramountplus\.com/);
api.unmap('m', /paramountplus\.com/);
api.unmap('f', /dailymotion\.com/);
api.unmap('m', /dailymotion\.com/);
api.unmap('/', /iview\.abc\.net\.au/);
api.unmap('f', /iview\.abc\.net\.au/);
api.unmap('m', /iview\.abc\.net\.au/);

// Google services
api.unmap('/', /drive\.google\.com/);
api.unmap('p', /docs\.google\.com/);
api.unmap('/', /docs\.google\.com/);
api.unmap('m', /docs\.google\.com/);
api.unmap('d', /calendar\.google\.com/);
api.unmap('m', /calendar\.google\.com/);

// Gmail - extensive pass-through for native shortcuts
api.unmap('/', /mail\.google\.com/);
api.unmap('a', /mail\.google\.com/);
api.unmap('b', /mail\.google\.com/);
api.unmap('d', /mail\.google\.com/);
api.unmap('e', /mail\.google\.com/);
api.unmap('f', /mail\.google\.com/);
api.unmap('g', /mail\.google\.com/);
api.unmap('i', /mail\.google\.com/);
api.unmap('j', /mail\.google\.com/);
api.unmap('k', /mail\.google\.com/);
api.unmap('l', /mail\.google\.com/);
api.unmap('m', /mail\.google\.com/);
api.unmap('r', /mail\.google\.com/);
api.unmap('v', /mail\.google\.com/);
api.unmap('x', /mail\.google\.com/);
api.unmap('X', /mail\.google\.com/);

// Other sites
api.unmap('/', /duckduckgo\.com/);
api.unmap('p', /containerstore\.com/);
api.unmap('b', /walmart\.wd5\.myworkdayjobs\.com/);
api.unmap('m', /walmart\.wd5\.myworkdayjobs\.com/);
api.unmap('p', /walmart\.wd5\.myworkdayjobs\.com/);
api.unmap('a', /localhost:2718/);
api.unmap('m', /localhost:2718/);

// ============================================
// OMNIBAR CUSTOMIZATION & THEME - Modular approach
// ============================================

// --- OMNIBAR SIZE/FONT (always applied) ---
const omnibarSizing = `
/* Omnibar - Main container */
#sk_omnibar {
    width: 80% !important;
    max-width: 1000px !important;
    font-size: 18px !important;
}

/* Omnibar - Input field */
#sk_omnibar input {
    font-size: 20px !important;
    padding: 16px 20px !important;
    font-family: 'Menlo', 'Monaco', monospace !important;
}

/* Omnibar - Result items */
#sk_omnibar li {
    font-size: 16px !important;
    padding: 12px 20px !important;
    line-height: 1.6 !important;
    font-family: 'Menlo', 'Monaco', monospace !important;
}

/* Omnibar - Result titles */
#sk_omnibar .title {
    font-size: 17px !important;
    font-weight: 600 !important;
}

/* Omnibar - URLs */
#sk_omnibar .url {
    font-size: 14px !important;
}
`;

// --- THEME: Catppuccin Macchiato (swappable) ---
const catppuccinTheme = `
/* Catppuccin Macchiato Palette */
:root {
  --sk-rosewater: #f4dbd6;
  --sk-peach: #f5a97f;
  --sk-green: #a6da95;
  --sk-blue: #8aadf4;
  --sk-lavender: #b7bdf8;
  --sk-text: #cad3f5;
  --sk-subtext0: #a5adcb;
  --sk-subtext1: #b8c0e0;
  --sk-surface2: #5b6078;
  --sk-surface1: #494d64;
  --sk-surface0: #363a4f;
  --sk-base: #24273a;
  --sk-mantle: #1e2030;
  --sk-crust: #181926;
}

/* Hint markers */
#sk_hints .begin {
    color: var(--sk-mantle) !important;
    background: var(--sk-green) !important;
    border: 1px solid var(--sk-mantle) !important;
}

#sk_hints .begin.focused {
    color: var(--sk-surface2) !important;
}

/* Omnibar colors */
#sk_omnibar {
    background: var(--sk-base);
    border: 2px solid var(--sk-lavender);
}

#sk_omnibar input {
    color: var(--sk-text);
    background: var(--sk-base);
}

#sk_omnibar .omnibar_timestamp {
    color: var(--sk-peach);
}

#sk_omnibar .omnibar_folder {
    color: var(--sk-blue);
}

#sk_omnibar .url {
    color: var(--sk-rosewater);
}

#sk_omnibar li.focused {
    background: var(--sk-surface0);
}

/* Status bar */
#sk_status {
    background: var(--sk-base);
    color: var(--sk-text);
    border: 1px solid var(--sk-text);
}

/* Visual mode */
.surfingkeys_visual_hints_host {
    background-color: var(--sk-peach) !important;
    color: var(--sk-mantle) !important;
}
`;

// --- COMBINE AND APPLY ---
settings.theme = omnibarSizing + catppuccinTheme;
