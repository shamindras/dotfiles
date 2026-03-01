// ============================================
// SURFINGKEYS CONFIGURATION
// Theme: Tomorrow Night (Foldex-style CSS variables)
// ============================================

// ============================================
// BASIC SETTINGS
// ============================================

// Show hints with 100ms delay for multi-key sequences
settings.richHintsForKeystroke = 100;

// Show omnibar suggestions instantly (for search engines, etc.)
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

// Remap f to open link hints in NEW tab
api.mapkey('f', '#1Open link hints in new tab', function() {
    api.Hints.create("", api.Hints.dispatchMouseClick, {tabbed: true});
});

// F for link hints in current tab (counterpart to f which opens in new tab)
api.mapkey('F', '#1Open link hints in current tab', function() {
    api.Hints.create("", api.Hints.dispatchMouseClick);
});

// Global gf mapping for link hints in new tab (useful on sites where f is unmapped)
api.mapkey('gf', '#1Open link hints in new tab', function() {
    api.Hints.create("", api.Hints.dispatchMouseClick, {tabbed: true});
});

// Move tab to start/end - use zh/zl to preserve marks (m key)
// Uses repeat prefix (99) with remapped < and > for atomic, reliable movement
api.mapkey('zh', '#3Move tab to beginning', function() {
    api.Normal.feedkeys('99<');
});
api.mapkey('zl', '#3Move tab to end', function() {
    api.Normal.feedkeys('99>');
});

// First/last tab shortcuts (gh/gl)
api.map('gh', 'g0');  // First tab
api.map('gl', 'g$');  // Last tab

// Close current tab with zz
api.map('zz', 'x');

// ============================================
// OMNIBAR & TAB MANAGEMENT - Vimium style
// ============================================

// o/O - Omnibar (Vimium convention: lowercase = new tab, uppercase = current tab)
api.mapkey('o', '#8Open URLs in new tab', function() {
    api.Front.openOmnibar({type: "URLs", tabbed: true});
});
api.map('O', 'go');  // O = omnibar, open in CURRENT tab

// t/T - Tab operations (Vimium convention)
// Using example.com as a lightweight page where SK keymaps work
api.mapkey('t', '#3Create new tab', function() {
    window.open('https://example.com', '_blank');
});

// gt - Fallback for t on restricted sites (e.g., YouTube)
api.mapkey('gt', '#3Create new tab (fallback)', function() {
    window.open('https://example.com', '_blank');
});

api.map('T', 'T');   // T = tab picker (default Surfingkeys 'T')

// B - Bookmarks in current tab (counterpart to b which opens in new tab)
api.mapkey('B', '#8Open bookmarks in current tab', function() {
    api.Front.openOmnibar({type: "Bookmarks", tabbed: false});
});

// Ctrl-x - Omnibar with recently closed URLs (relocated from ox)
api.mapkey('<Ctrl-x>', '#8Open recently closed URLs', function() {
    api.Front.openOmnibar({type: "URLs", extra: "recentlyClosed"});
});

// ;i - Open incognito window (relocated from oi)
api.mapkey(';i', '#3Open incognito window', function() {
    api.RUNTIME("openIncognito", {url: window.location.href});
});

// ============================================
// THESAURUS - Inline synonym lookup
// ============================================

// Ctrl-t - Open thesaurus omnibar
api.mapkey('<Ctrl-t>', '#8Open thesaurus', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "th"});
});

// ============================================
// YANK COMMANDS
// ============================================

// Helper function to create markdown link with two-stage title trimming
// Stage 1: Trim at first delimiter (" - ", " | ", " : ")
// Stage 2: If no delimiters, take first contiguous word (before first space)
// Examples:
//   "GitHub - microsoft/vscode" -> "GitHub"
//   "Anna's Archive | Books" -> "Anna's Archive"
//   "dotfiles/.config/file.lua at main" -> "dotfiles/.config/file.lua"
const createMarkdownLink = (text, url) => {
    let trimmedText;

    // Stage 1: Try to trim at delimiters: " - ", " | ", " : "
    const delimiterMatch = text.match(/^(.*?)(\s-\s|\s\|\s|\s:\s)/);
    if (delimiterMatch) {
        trimmedText = delimiterMatch[1];
    } else {
        // Stage 2: No delimiters found, take first contiguous word (before first space)
        trimmedText = text.split(/\s/)[0];
    }

    // Final trim to handle any extra spaces on left and right
    return `[${trimmedText.trim()}](${url})`;
};

// ym - Yank current page as markdown link: [title](url)
api.mapkey('ym', '#7Copy current page as markdown link', function() {
    const title = document.title;
    const url = window.location.href;
    const markdown = createMarkdownLink(title, url);
    api.Clipboard.write(markdown);
    api.Front.showBanner(`Copied: ${markdown}`);
});

// ya - Yank anchor as markdown link via hints: [link text](url)
api.mapkey('ya', '#7Yank anchor as markdown link', function() {
    api.Hints.create("", function(element) {
        let link, url, text;

        // Try to find actual <a> tag
        link = element.tagName === 'A' ? element : element.closest('a');

        if (link && link.href) {
            url = link.href;
            text = (link.innerText || link.textContent || url).trim();
        } else {
            // Fallback: check for data-href or other attributes
            url = element.getAttribute('data-href') ||
                  element.getAttribute('href') ||
                  element.closest('[data-href]')?.getAttribute('data-href');
            text = (element.innerText || element.textContent || '').trim();
        }

        if (!url) {
            api.Front.showBanner('No valid link found');
            return;
        }

        const markdown = createMarkdownLink(text || url, url);
        api.Clipboard.write(markdown);
        api.Front.showBanner(`Copied: ${markdown}`);
    });
});

// yf - Yank followed link URL to clipboard via hints
api.mapkey('yf', '#7Yank followed link URL', function() {
    api.Hints.create('*[href]', function(element) {
        api.Clipboard.write(element.href);
    });
});

// yp - Yank page form data as JSON
api.mapkey('yp', '#7Yank page form data as JSON', function() {
    var formData = {};
    var inputs = document.querySelectorAll('input[name], select[name], textarea[name]');

    inputs.forEach(function(el) {
        var name = el.name;
        if (!name) return;

        if (el.type === 'checkbox') {
            // Collect multiple checkboxes with same name into an array
            if (formData.hasOwnProperty(name)) {
                if (!Array.isArray(formData[name])) {
                    formData[name] = [formData[name]];
                }
                if (el.checked) {
                    formData[name].push(el.value);
                }
            } else {
                formData[name] = el.checked ? el.value : null;
            }
        } else if (el.type === 'radio') {
            // Only capture the selected radio in each group
            if (el.checked) {
                formData[name] = el.value;
            } else if (!formData.hasOwnProperty(name)) {
                formData[name] = null;
            }
        } else if (el.type === 'file') {
            // Can't serialize file contents, just capture the filename
            formData[name] = el.value || null;
        } else {
            formData[name] = el.value;
        }
    });

    var json = JSON.stringify(formData, null, 2);
    api.Clipboard.write(json);
    api.Front.showBanner('Copied form data: ' + Object.keys(formData).length + ' field(s)');
});

// yM - Yank all tabs as markdown links (one per line, sorted by tab index)
api.mapkey('yM', '#7Yank all tabs as markdown links', function() {
    api.RUNTIME("getTabs", {}, function(response) {
        var tabs = response.tabs;
        var keys = Object.keys(tabs);
        var lines = keys
            .sort(function(a, b) { return tabs[a].index - tabs[b].index; })
            .map(function(key) {
                return createMarkdownLink(tabs[key].title || tabs[key].url, tabs[key].url);
            });
        var result = lines.join('\n');
        api.Clipboard.write(result);
        api.Front.showBanner('Copied ' + lines.length + ' tab(s) as markdown links\n' + result);
    });
});

// ============================================
// VIM-STYLE SCROLLING (from Foldex)
// ============================================

// Note: Ctrl-d and Ctrl-u removed to free up for other features
// Use 'd' and 'u' for half-page scrolling instead

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
api.removeSearchAlias('s');  // Remove Stack Overflow (will re-add softarchive)
api.removeSearchAlias('w');  // Remove Bing
api.removeSearchAlias('y');  // Remove YouTube (will re-add)

// STEP 2: Add our custom search engines with suggestion support
api.addSearchAlias('b', 'imdb', 'http://www.imdb.com/find?s=all&q=');
api.addSearchAlias('g', 'google', 'https://www.google.com/search?q=', 's', 'https://www.google.com/complete/search?client=chrome&q=', function(response) {
    var res = JSON.parse(response.text);
    return res[1];
});
api.addSearchAlias('k', 'duckduckgo', 'https://duckduckgo.com/?q=', 's', 'https://duckduckgo.com/ac/?q=', function(response) {
    var res = JSON.parse(response.text);
    return res.map(function(r){
        return r.phrase;
    });
});
api.addSearchAlias('l', 'libgen', 'https://libgen.li/index.php?columns%5B%5D=t&columns%5B%5D=a&columns%5B%5D=s&columns%5B%5D=y&columns%5B%5D=p&columns%5B%5D=i&objects%5B%5D=f&objects%5B%5D=e&objects%5B%5D=s&objects%5B%5D=a&objects%5B%5D=p&objects%5B%5D=w&topics%5B%5D=l&res=100&filesuns=all&curtab=f&order=year&ordermode=desc&req=');
api.addSearchAlias('m', 'google-maps', 'https://www.google.com/maps?q=', 's', 'https://www.google.com/complete/search?client=chrome&q=', function(response) {
    var res = JSON.parse(response.text);
    return res[1];
});
api.addSearchAlias('n', 'annas-archive', 'https://annas-archive.li/search?index=&page=1&sort=newest&content=book_nonfiction&content=book_fiction&content=book_unknown&ext=pdf&ext=epub&lang=en&display=list_compact&q=');
api.addSearchAlias('s', 'softarchive', 'https://softarchive.download/search?scope=title&category=5&q=', 's', 'https://softarchive.download/ajax/getSearchKeywords.ajax.php?q=', function(response) {
    return JSON.parse(response.text);
});
api.addSearchAlias('w', 'wikipedia', 'https://www.wikipedia.org/w/index.php?title=Special:Search&search=', 's', 'https://en.wikipedia.org/w/api.php?action=opensearch&format=json&formatversion=2&namespace=0&limit=40&search=', function(response) {
    var res = JSON.parse(response.text);
    return res[1];
});
api.addSearchAlias('y', 'youtube', 'https://www.youtube.com/results?search_query=', 's', 'https://clients1.google.com/complete/search?client=youtube&ds=yt&q=', function(response) {
    // YouTube returns JSONP, need to extract JSON array
    var match = response.text.match(/\[.*\]/);
    if (match) {
        var res = JSON.parse(match[0]);
        return res[1].map(function(item) {
            return item[0];
        });
    }
    return [];
});
api.addSearchAlias('th', 'thesaurus', 'https://www.onelook.com/thesaurus/?s=', 's', 'https://api.datamuse.com/words?md=d&rel_syn=', function(response) {
    var res = JSON.parse(response.text);
    return res.slice(0, 15).map(function(item) {
        var word = item.word;
        var defs = item.defs || [];
        var pos = '';
        var defText = '';

        if (defs.length > 0) {
            var parts = defs[0].split('\t');
            if (parts.length >= 2) {
                pos = parts[0];
                defText = parts.slice(1).join(' ');
            }
        }

        var displayTitle = word;
        if (pos) displayTitle += ' (' + pos + ')';

        if (defText.length > 80) {
            defText = defText.substring(0, 80) + '...';
        }

        return {
            title: displayTitle,
            url: 'https://www.onelook.com/thesaurus/?s=' + encodeURIComponent(word),
            annotation: defText
        };
    });
});
api.addSearchAlias('de', 'dictionary', 'https://www.onelook.com/?w=', 's', 'https://api.datamuse.com/words?qe=sp&md=d&max=1&sp=', function(response) {
    var res = JSON.parse(response.text);
    if (res.length === 0) return [];

    var word = res[0].word;
    var defs = res[0].defs || [];

    var groups = { 'adj': [], 'n': [], 'v': [], 'adv': [] };

    defs.forEach(function(def) {
        var parts = def.split('\t');
        if (parts.length >= 2) {
            var pos = parts[0];
            var defText = parts.slice(1).join(' ');
            if (groups[pos]) {
                groups[pos].push(defText);
            }
        }
    });

    var results = [];
    var order = ['adj', 'n', 'v', 'adv'];

    order.forEach(function(pos) {
        if (groups[pos].length > 0) {
            var firstDef = groups[pos][0];
            if (firstDef.length > 100) {
                firstDef = firstDef.substring(0, 97) + '...';
            }
            results.push(word + ' (' + pos + '): ' + firstDef);
        }
    });

    return results;
});
api.addSearchAlias('z', 'amazon-au', 'https://www.amazon.com.au/s/?field-keywords=', 's', 'https://completion.amazon.com.au/api/2017/suggestions?mid=A39IBJ37TRP1C6&alias=aps&prefix=', function(response) {
    var res = JSON.parse(response.text);
    return res.suggestions.map(function(item) {
        return item.value;
    });
});
api.addSearchAlias('e', 'homebrew', 'https://www.google.com/search?btnI&q=site:formulae.brew.sh+', 's', 'https://www.google.com/complete/search?client=chrome&q=site:formulae.brew.sh+', function(response) {
    var res = JSON.parse(response.text);
    return res[1];
});
api.addSearchAlias('q', 'quick-google', 'https://www.google.com/search?btnI&q=', 's', 'https://www.google.com/complete/search?client=chrome&q=', function(response) {
    var res = JSON.parse(response.text);
    return res[1];
});

// STEP 3: Remove auto-generated o* mappings (we use Ctrl-* instead)
api.unmap('ob');
api.unmap('ode');
api.unmap('oe');
api.unmap('og');
api.unmap('ok');
api.unmap('ol');
api.unmap('om');
api.unmap('on');
api.unmap('oq');
api.unmap('os');
api.unmap('oth');
api.unmap('ow');
api.unmap('oy');
api.unmap('oz');

// STEP 4: Add Ctrl-based shortcuts for quick access (matches Vimium)
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
api.mapkey('<Ctrl-s>', 'Search Softarchive', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "s"});
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
api.mapkey('<Ctrl-e>', 'Search Homebrew (Environment)', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "e"});
});
api.mapkey('<Ctrl-q>', 'Quick Google (I\'m Feeling Lucky)', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "q"});
});
api.mapkey('<Ctrl-d>', 'Search Dictionary', function() {
    api.Front.openOmnibar({type: "SearchEngine", extra: "de"});
});


// ============================================
// SITE EXCLUSIONS - Port from Vimium
// ============================================

// COMPLETELY DISABLE Surfingkeys on these sites
settings.blocklistPattern = /localhost:888[89]|localhost:8890|multiplexer-prod\.datacamp\.com|app\.gather\.town|type-fu\.com|app\.coderpad\.io|games\.usatoday\.com|vimaroo\.vercel\.app|static\.licdn\.com|cocalc\.com\/projects|docs\.google\.com\/(document|presentation)/i;

// ============================================
// SITE-SPECIFIC KEY UNMAPPING
// ============================================

// ========== VIDEO SITES ==========

// YouTube - Unmap keys on entire domain
['f', 'm', 't', 'c'].forEach(key => {
    api.unmap(key, /youtube\.com/);
});

// Netflix - domain-wide (SPA site)
['f', 'm'].forEach(key => {
    api.unmap(key, /netflix\.com/);
});

// Amazon Video - domain-wide for /gp/video section
['f', 'm'].forEach(key => {
    api.unmap(key, /amazon\.com/);
});

// Prime Video - domain-wide
['f', 'm'].forEach(key => {
    api.unmap(key, /primevideo\.com/);
});

// Crunchyroll - domain-wide (handles both main and static domains)
['f', 'm', 'c', 'j', 'k'].forEach(key => {
    api.unmap(key, /crunchyroll\.com/);
});

// HiAnime - domain-wide
['f', 'm'].forEach(key => {
    api.unmap(key, /hianime\.to/);
});

// AniCrush - domain-wide
['f', 'm'].forEach(key => {
    api.unmap(key, /anicrush\.to/);
});

// Bilibili - domain-wide
api.unmap('f', /bilibili\.com/);

// Peacock - domain-wide
['f', 'm'].forEach(key => {
    api.unmap(key, /peacocktv\.com/);
});

// Paramount+ - domain-wide
['f', 'm'].forEach(key => {
    api.unmap(key, /paramountplus\.com/);
});

// Dailymotion - domain-wide
['f', 'm'].forEach(key => {
    api.unmap(key, /dailymotion\.com/);
});

// iView ABC - domain-wide
['f', 'm'].forEach(key => {
    api.unmap(key, /iview\.abc\.net\.au/);
});

// iView ABC - Use runtime conditional for / remapping
if (/iview\.abc\.net\.au/.test(window.location.host)) {
    api.unmap('/');
    api.mapkey('/', '#0Focus iView search', function() {
        const searchInput = document.querySelector('input[type="search"]') ||
                           document.querySelector('input[placeholder*="Search"]');
        if (searchInput) searchInput.focus();
    });
}

// ========== GOOGLE SERVICES ==========

// Gmail - Unmap keys to allow native Gmail shortcuts (except 'i', 'l', 'd', and 'u' for Surfingkeys)
['a', 'b', 'c', 'e', 'f', 'g', 'j', 'k', 'm', 'r', 'v', 'x', 'X'].forEach(key => {
    api.unmap(key, /mail\.google\.com/);
});

// Gmail - Custom z-prefixed navigation shortcuts (to avoid conflict with Gmail's g shortcuts)
// Helper function to navigate to Gmail views with correct account
const gmailNavigate = (view) => {
    const accountMatch = window.location.pathname.match(/\/u\/(\d+)\//);
    const accountNum = accountMatch ? accountMatch[1] : '0';
    window.location.href = `https://mail.google.com/mail/u/${accountNum}/#${view}`;
};

api.mapkey('agi', '#0Go to inbox', () => gmailNavigate('inbox'), {domain: /mail\.google\.com/i});
api.mapkey('ags', '#0Go to starred', () => gmailNavigate('starred'), {domain: /mail\.google\.com/i});
api.mapkey('agt', '#0Go to sent', () => gmailNavigate('sent'), {domain: /mail\.google\.com/i});
api.mapkey('agd', '#0Go to drafts', () => gmailNavigate('drafts'), {domain: /mail\.google\.com/i});
api.mapkey('aga', '#0Go to all mail', () => gmailNavigate('all'), {domain: /mail\.google\.com/i});
api.mapkey('agz', '#0Go to snoozed', () => gmailNavigate('snoozed'), {domain: /mail\.google\.com/i});

// Gmail - Use runtime conditional for / remapping
if (/mail\.google\.com/.test(window.location.host)) {
    api.unmap('/');
    api.mapkey('/', '#0Focus Gmail search', function() {
        const searchInput = document.querySelector('input[aria-label*="Search"]') ||
                           document.querySelector('input[name="q"]');
        if (searchInput) searchInput.focus();
    });
}

// Google Drive - Use runtime conditional for / remapping
if (/drive\.google\.com/.test(window.location.host)) {
    api.unmap('/');
    api.mapkey('/', '#0Focus Drive search', function() {
        const searchInput = document.querySelector('input[aria-label*="Search"]') ||
                           document.querySelector('input[placeholder*="Search"]');
        if (searchInput) searchInput.focus();
    });
}

// Google Docs
['p', 'm'].forEach(key => {
    api.unmap(key, /docs\.google\.com/);
});

// Google Docs - Use runtime conditional for / remapping
if (/docs\.google\.com/.test(window.location.host)) {
    api.unmap('/');
    api.mapkey('/', '#0Open Docs find', function() {
        document.dispatchEvent(new KeyboardEvent('keydown', {
            key: 'f',
            code: 'KeyF',
            ctrlKey: true,
            bubbles: true
        }));
    });
}

// Google Calendar
['d', 'm'].forEach(key => {
    api.unmap(key, /calendar\.google\.com/);
});

// ========== OTHER SITES ==========

// DuckDuckGo - Use runtime conditional for / remapping
if (/duckduckgo\.com/.test(window.location.host)) {
    api.unmap('/');
    api.mapkey('/', '#0Focus DuckDuckGo search', function() {
        const searchInput = document.querySelector('input#search_form_input') ||
                           document.querySelector('input[name="q"]') ||
                           document.querySelector('input[type="search"]');
        if (searchInput) searchInput.focus();
    });
}

// Container Store
api.unmap('p', /containerstore\.com/);

// Walmart Jobs
['b', 'm', 'p'].forEach(key => {
    api.unmap(key, /walmart\.wd5\.myworkdayjobs\.com/);
});

// Localhost:2718
['a', 'm'].forEach(key => {
    api.unmap(key, /localhost:2718/);
});

// ============================================
// THEME: TOMORROW NIGHT (Foldex-style)
// ============================================

// Hint styling - 12pt with monospace font matching keystroke popup style
api.Hints.style('border: solid 2px #373B41; color:#52C196; background: initial; background-color: #1D1F21; font-size: 12pt; font-weight: bold; padding: 4px 7px; font-family: "Menlo", "Monaco", "Source Code Pro", monospace;');
api.Hints.style("border: solid 2px #373B41 !important; padding: 4px 7px !important; color: #C5C8C6 !important; background: #1D1F21 !important; font-size: 12pt !important; font-weight: bold !important; font-family: 'Menlo', 'Monaco', 'Source Code Pro', monospace !important;", "text");
api.Visual.style('marks', 'background-color: #52C19699;');
api.Visual.style('cursor', 'background-color: #81A2BE;');

// Main theme
settings.theme = `
/* ===== TOMORROW NIGHT THEME ===== */

:root {
  --font: 'Menlo', 'Monaco', 'Source Code Pro', monospace;
  --font-size: 12pt;
  --font-weight: normal;
  --fg: #C5C8C6;
  --bg: #282A2E;
  --bg-dark: #1D1F21;
  --border: #373b41;
  --main-fg: #81A2BE;
  --accent-fg: #52C196;
  --info-fg: #AC7BBA;
  --select: #585858;
}

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

#sk_omnibar {
  width: 95%;
  max-width: 1000px;
  background: var(--bg) !important;
  border: 2px solid var(--border);
  padding: 15px;
}

.sk_theme .title {
  color: var(--accent-fg) !important;
  font-size: 14pt !important;
}

.sk_theme .url {
  color: var(--main-fg) !important;
  font-size: 13pt !important;
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

.sk_theme #sk_omnibarSearchResult ul li {
  background: var(--bg-dark) !important;
  font-size: 14pt !important;
  padding: 10px 14px !important;
}

.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
  background: var(--bg-dark) !important;
}

.sk_theme #sk_omnibarSearchResult ul li:nth-child(even) {
  background: var(--bg-dark) !important;
}

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
  padding: 8px 0;
}

.sk_theme #sk_omnibarSearchArea input,
.sk_theme #sk_omnibarSearchArea span {
  font-size: 16pt;
  color: var(--fg) !important;
  background: var(--bg) !important;
}

.sk_theme .separator {
  color: var(--accent-fg) !important;
}

#sk_banner {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
  background: var(--bg) !important;
  border-color: var(--border);
  color: var(--fg) !important;
  opacity: 0.9;
}

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
`
