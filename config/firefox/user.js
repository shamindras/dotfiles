// user.js — Firefox about:config preference overrides
//
// Source of truth: config/firefox/user.js in dotfiles repo.
// Firefox reads this file on every startup and applies values to prefs.js.
// Firefox never writes back to user.js, so it is safe for version control.
//
// To change a setting: edit this file, run `just firefox_sync`, restart Firefox.

// =============================================================================
// Privacy {{{
// =============================================================================

// Studies, telemetry, and Normandy are disabled and locked via policies.json
// (DisableFirefoxStudies, DisableTelemetry, nimbus.rollouts, app.normandy).
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);

// }}}

// =============================================================================
// Telemetry Detail — supplements DisableTelemetry policy in policies.json {{{
// =============================================================================

// Web Beacon API (analytics/tracking pings)
user_pref("beacon.enabled", false);
// New tab page telemetry
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
// Ping Centre telemetry
user_pref("browser.ping-centre.telemetry", false);
// Code coverage telemetry
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
// Crash report submission
user_pref("breakpad.reportURL", "");
// Extension metadata daily phone-home
user_pref("extensions.getAddons.cache.enabled", false);
user_pref("extensions.getAddons.showPane", false);
// Content blocking reports
user_pref("browser.contentblocking.report.monitor.enabled", false);
user_pref("browser.contentblocking.report.vpn.enabled", false);

// }}}

// =============================================================================
// AI / ML — managed and locked via policies.json (GenerativeAI policy +
// browser.ai.control.* + browser.ml.* prefs). See config/firefox/policies.json.
// =============================================================================

// =============================================================================
// Search & URL Bar {{{
// =============================================================================

user_pref("browser.search.suggest.enabled", false);
user_pref("browser.search.visualSearch.featureGate", false);
user_pref("browser.urlbar.shortcuts.actions", false);
user_pref("browser.urlbar.shortcuts.bookmarks", false);
user_pref("browser.urlbar.shortcuts.history", false);
user_pref("browser.urlbar.shortcuts.tabs", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.quicksuggest.all", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.searches", false);
user_pref("browser.urlbar.suggest.topsites", false);

// }}}

// =============================================================================
// New Tab Page {{{
// =============================================================================

// Pocket, sponsored content, and top sites are disabled and locked via
// policies.json (DisablePocket + FirefoxHome). Checkbox visibility below
// is not covered by FirefoxHome, so it stays here.
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);

// }}}

// =============================================================================
// Network {{{
// =============================================================================

user_pref("network.dns.disablePrefetch", true);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("network.prefetch-next", false);

// }}}

// =============================================================================
// Sidebar & Tabs {{{
// =============================================================================

user_pref("browser.tabs.groups.smart.enabled", false);
user_pref("browser.tabs.groups.smart.searchTopicEnabled", false);
user_pref("browser.tabs.groups.smart.userEnabled", false);
user_pref("sidebar.position_start", false);
user_pref("sidebar.revamp", true);
user_pref("sidebar.verticalTabs", true);

// }}}

// =============================================================================
// Media {{{
// =============================================================================

user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);

// }}}

// =============================================================================
// PDF Viewer {{{
// =============================================================================

user_pref("pdfjs.defaultZoomValue", "page-fit");
user_pref("pdfjs.sidebarViewOnLoad", 0);
user_pref("pdfjs.spreadModeOnLoad", 1);

// }}}

// =============================================================================
// UI {{{
// =============================================================================

user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.theme.toolbar-theme", 0);
user_pref("browser.toolbars.bookmarks.visibility", "never");
user_pref("layout.css.prefers-color-scheme.content-override", 0);

// }}}

// =============================================================================
// Session & Auth {{{
// =============================================================================

// Restore previous session on startup
user_pref("browser.startup.page", 3);
// Homepage
user_pref("browser.startup.homepage", "https://example.com/");
// Password manager disabled and locked via policies.json (PasswordManagerEnabled)
// Decline syncing passwords and credit cards
user_pref("services.sync.engine.passwords", false);

// }}}

// =============================================================================
// Security {{{
// =============================================================================

// HTTPS-only mode (shows warning page for HTTP sites, click-through allowed)
user_pref("dom.security.https_only_mode", true);

// }}}

// =============================================================================
// Performance {{{
// =============================================================================

// Reduce per-tab back/forward history (50 → 10, saves memory)
user_pref("browser.sessionhistory.max_entries", 10);
// Back/forward cache — instant Back button (-1 = auto-managed by Firefox)
user_pref("browser.sessionhistory.max_viewers", -1);
// Save session state less frequently (15s → 60s, reduces disk I/O)
user_pref("browser.sessionstore.interval", 60000);
// Unload inactive tabs under memory pressure (tabs reload on click)
user_pref("browser.tabs.unloadOnLowMemory", true);
// Use Apple Silicon hardware video decoder (less CPU, better battery)
user_pref("media.hardware-video-decoding.enabled", true);

// }}}

// =============================================================================
// Context Menu Cleanup (about:config) {{{
// =============================================================================

// Required: use Firefox-drawn menus so userChrome.css rules apply
user_pref("widget.macos.native-context-menus", false);
// Remove "Translate Selection"
user_pref("browser.translations.select.enable", false);
// Remove "Take Screenshot"
user_pref("screenshots.browser.component.enabled", false);
// Remove "Go to highlighted text"
user_pref("dom.text_fragments.enabled", false);
// Remove "Copy Clean Link"
user_pref("privacy.query_stripping.strip_on_share.enabled", false);
// Remove Accessibility inspector
user_pref("devtools.accessibility.enabled", false);
// Remove "Recognize Text in Image"
user_pref("dom.text-recognition.enabled", false);
// Remove "Fill Address"
user_pref("extensions.formautofill.addresses.enabled", false);
// Remove "Fill Credit Card"
user_pref("extensions.formautofill.creditCards.enabled", false);

// }}}

// =============================================================================
// userChrome.css support {{{
// =============================================================================

// Enable loading of chrome/userChrome.css from profile directory
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// }}}
