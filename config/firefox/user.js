// user.js — Firefox about:config preference overrides
//
// Source of truth: config/firefox/user.js in dotfiles repo.
// Firefox reads this file on every startup and applies values to prefs.js.
// Firefox never writes back to user.js, so it is safe for version control.
//
// To change a setting: edit this file, run `just firefox_sync`, restart Firefox.

// =============================================================================
// Privacy & Telemetry {{{
// =============================================================================

user_pref("app.shield.optoutstudies.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.usage.uploadEnabled", false);
user_pref("nimbus.rollouts.enabled", false);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);

// }}}

// =============================================================================
// AI / ML (all off) {{{
// =============================================================================

user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.hideLocalhost", false);
user_pref("browser.ml.chat.menu", false);
user_pref("browser.ml.chat.page", false);
user_pref("browser.ml.chat.page.footerBadge", false);
user_pref("browser.ml.chat.page.menuBadge", false);
user_pref("browser.ml.chat.shortcuts", false);
user_pref("browser.ml.chat.shortcuts.custom", false);
user_pref("browser.ml.chat.sidebar", false);
user_pref("browser.ml.checkForMemory", false);
user_pref("browser.ml.enable", false);
user_pref("browser.ml.linkPreview.blockListEnabled", false);
user_pref("browser.ml.linkPreview.collapsed", true);
user_pref("browser.ml.linkPreview.longPress", false);
user_pref("extensions.ml.enabled", false);

// }}}

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

user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

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
// Do not save passwords in Firefox (use a dedicated password manager)
user_pref("signon.rememberSignons", false);
// Decline syncing passwords and credit cards
user_pref("services.sync.engine.passwords", false);

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
