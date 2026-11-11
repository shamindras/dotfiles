#!/usr/bin/env python3
"""Unit tests for scripts/ops/manifest (the resolver). Stdlib unittest only.

Run: python3 scripts/test/manifest_test.py [-v] [TestCase[.test]]
Each test builds a small in-memory manifest; nothing on disk is touched
except a mktemp dir for the link-source check.
"""

import copy
import importlib.machinery
import importlib.util
import json
import os
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
_path = os.path.join(HERE, "..", "ops", "manifest")
_loader = importlib.machinery.SourceFileLoader("manifest", _path)
_spec = importlib.util.spec_from_loader("manifest", _loader)
mf = importlib.util.module_from_spec(_spec)
_loader.exec_module(mf)
with open(mf.SCHEMA) as _f:
    SCHEMA = json.load(_f)

SETTINGS = {"repos_dir": "$HOME/repos", "notes_dir": "$HOME/notes", "remote_login": False, "quarantine_warning": True}

BASE = {
    "schema_version": 1,
    "taps": {"acme/tap": {"trusted": True}},
    "roles": {"browser": {"note": "fixture role"}},
    "modules": {
        "core": {"note": "core tools", "brew": ["fd", "ripgrep"]},
        "desktop": {"note": "desktop", "cask": ["acme/tap/winmgr"]},
        "fonts": {"note": "fonts", "cask": ["font-mono"]},
        "personal": {"note": "home only", "cask": ["spotify"]},
    },
    "units": {
        "bar": {"module": "desktop", "brew": ["acme/tap/bar"], "requires": ["wm"], "service": "bar"},
        "term": {
            "module": "core",
            "cask": ["term"],
            "links": {"${XDG_CONFIG_HOME}/term": "config/term"},
            "setup": [{"command": "term --init", "description": "init", "needs": ["term"]}],
            "requires": ["font-mono"],
            "app": {"path": "/Applications/Term.app", "bundle_id": "com.acme.term", "leader": "t", "workspace": "T"},
        },
        "browser": {
            "module": "core",
            "cask": ["browser"],
            "links": {"${XDG_CONFIG_HOME}/browser": "config/browser"},
            "setup": [{"command": "browser --setup", "description": "setup"}],
            "app": {"path": "/Applications/Browser.app", "bundle_id": "com.acme.browser", "leader": "b"},
        },
        "music": {
            "module": "personal",
            "app": {"path": "/Applications/Music.app", "bundle_id": "com.acme.music", "leader": "m"},
        },
        "wm": {"module": "desktop", "requires": ["bar"], "setup": [{"command": "wm --reload", "description": "reload"}]},
    },
    "profiles": {
        "home": {"modules": ["core", "desktop", "personal"], "roles": {"browser": "browser"}, "settings": SETTINGS},
        "work": {
            "modules": ["core"],
            "units": {"browser": "external", "music": "off"},
            "roles": {"browser": "browser"},
            "settings": SETTINGS,
        },
    },
}


def manifest(**changes):
    m = copy.deepcopy(BASE)
    for path, value in changes.items():
        node = m
        keys = path.split("__")
        for k in keys[:-1]:
            node = node[k]
        if value is None:
            del node[keys[-1]]
        else:
            node[keys[-1]] = value
    return m


def errors(m):
    errs = mf.validate(m, SCHEMA)
    if errs:
        return errs
    errs = mf.semantic_errors(m, check_files=False)
    for p in sorted(m["profiles"]):
        errs += mf.resolve(m, p)[3]
    return errs


class SchemaTest(unittest.TestCase):
    def test_base_fixture_is_valid(self):
        self.assertEqual(errors(manifest()), [])

    def test_unknown_unit_key_is_rejected(self):
        m = manifest()
        m["units"]["term"]["colour"] = "blue"
        self.assertTrue(any("unknown key 'colour'" in e for e in errors(m)))

    def test_bad_state_is_rejected(self):
        m = manifest()
        m["profiles"]["work"]["units"]["term"] = "maybe"
        self.assertTrue(any("not one of" in e for e in errors(m)))

    def test_missing_setting_is_rejected(self):
        m = manifest()
        del m["profiles"]["home"]["settings"]["notes_dir"]
        self.assertTrue(any("notes_dir" in e for e in errors(m)))


class ClosureTest(unittest.TestCase):
    def test_required_unit_from_an_off_module_is_pulled_in(self):
        states, reasons, _, errs = mf.resolve(manifest(), "work")
        self.assertEqual(errs, [])
        self.assertEqual(states["font-mono"], "managed")
        self.assertEqual(reasons["font-mono"], "required by term")

    def test_off_but_required_names_both_units(self):
        m = manifest()
        m["profiles"]["work"]["units"]["font-mono"] = "off"
        errs = mf.resolve(m, "work")[3]
        self.assertEqual(errs, ["profile work: term requires font-mono, but font-mono is off"])

    def test_mutual_pair_resolves_together_and_dependencies_come_first(self):
        m = manifest()
        m["units"]["term"]["requires"] = ["font-mono", "wm"]
        states, _, order, errs = mf.resolve(m, "work")
        self.assertEqual(errs, [])
        self.assertEqual((states["wm"], states["bar"]), ("managed", "managed"))
        for dep in ("wm", "bar", "font-mono"):
            self.assertLess(order.index(dep), order.index("term"))
        self.assertEqual(abs(order.index("wm") - order.index("bar")), 1)

    def test_role_naming_an_off_unit_fails(self):
        m = manifest()
        m["profiles"]["work"]["units"]["browser"] = "off"
        self.assertIn("profile work: role browser names browser, which is off", mf.resolve(m, "work")[3])


class RulesTest(unittest.TestCase):
    def test_leader_keys_unique_per_profile(self):
        # Give music term's key "t": a clash at home (both on), fine at work (music off).
        m = manifest(**{"units__music__app__leader": "t"})
        self.assertEqual(mf.resolve(m, "home")[3], ["profile home: leader key t is used by music and term"])
        self.assertEqual(mf.resolve(m, "work")[3], [])

    def test_role_leader_goes_to_the_unit_filling_the_role(self):
        m = manifest(**{"roles__browser__leader": "r"})
        states = mf.resolve(m, "work")[0]
        self.assertEqual(mf.leader_map(m, "work", states)[0]["r"], "browser")
        resolved = json.loads(mf.render_profile(m, "work")["resolved.json"])
        self.assertEqual(resolved["leaders"]["r"], "browser")

    def test_role_leader_clashing_with_a_unit_key_fails(self):
        m = manifest(**{"roles__browser__leader": "t"})
        self.assertIn("profile work: leader key t is used by term and browser", mf.resolve(m, "work")[3])

    def test_unknown_role_fails(self):
        m = manifest()
        m["profiles"]["home"]["roles"]["editor"] = "term"
        self.assertTrue(any("editor" in e for e in errors(m)))

    def test_package_declared_twice_fails(self):
        m = manifest()
        m["units"]["browser"]["brew"] = ["fd"]
        self.assertIn("package fd is declared twice: module core and unit browser", errors(m))

    def test_unknown_requires_fails(self):
        m = manifest()
        m["units"]["wm"]["requires"] = ["nope"]
        self.assertIn("unit wm requires unknown unit nope", errors(m))

    def test_undeclared_tap_fails(self):
        m = manifest()
        m["units"]["browser"]["brew"] = ["other/tap/thing"]
        self.assertIn("unit browser: tap other/tap is not declared in taps", errors(m))

    def test_link_sources_must_exist(self):
        with tempfile.TemporaryDirectory() as root:
            os.makedirs(os.path.join(root, "config", "term"))
            errs = mf.semantic_errors(manifest(), root=root, check_files=True)
        self.assertEqual(errs, ["unit browser: link source config/browser does not exist"])

    def test_link_destination_claimed_twice_fails(self):
        m = manifest()
        m["units"]["browser"]["links"] = {"${XDG_CONFIG_HOME}/term": "config/browser"}
        self.assertIn("link ${XDG_CONFIG_HOME}/term is claimed by browser and term", errors(m))


class ProfileLinkTest(unittest.TestCase):
    def test_profile_placeholder_is_replaced_per_profile(self):
        m = manifest()
        m["units"]["browser"]["links"]["${XDG_CONFIG_HOME}/dotfiles/env.sh"] = "generated/{profile}/env.sh"
        for p in ("home", "work"):
            dotbot = json.loads(mf.render_profile(m, p)["dotbot.json"])
            links = [d["link"] for d in dotbot if "link" in d][0]
            self.assertEqual(links["${XDG_CONFIG_HOME}/dotfiles/env.sh"], "generated/%s/env.sh" % p)


class LinkOrderTest(unittest.TestCase):
    def test_links_to_links_come_after_their_targets(self):
        m = manifest()
        m["units"]["term"]["links"] = {"${XDG_CONFIG_HOME}/term": "config/term", "${HOME}/.termrc": "${XDG_CONFIG_HOME}/term/rc"}
        dotbot = json.loads(mf.render_profile(m, "home")["dotbot.json"])
        order = list([d["link"] for d in dotbot if "link" in d][0])
        self.assertGreater(order.index("${HOME}/.termrc"), order.index("${XDG_CONFIG_HOME}/term"))


class RenderTest(unittest.TestCase):
    def setUp(self):
        self.home = mf.render_profile(manifest(**{"units__term__requires": ["font-mono", "wm"]}), "home")
        self.work = mf.render_profile(manifest(), "work")

    def test_off_unit_leaves_no_package_link_step_or_binding(self):
        # inv-off-unit-leaves-nothing: wm, bar and spotify are off at work.
        brewfile = self.work["Brewfile"]
        dotbot = json.loads(self.work["dotbot.json"])
        resolved = json.loads(self.work["resolved.json"])
        self.assertNotIn("acme/tap/bar", brewfile)
        self.assertNotIn("spotify", brewfile)
        self.assertNotIn('tap "acme/tap"', brewfile)
        commands = [s["command"] for d in dotbot if "shell" in d for s in d["shell"]]
        self.assertFalse(any("wm --reload" in c or "restart bar" in c for c in commands))
        self.assertNotIn("music", resolved["units"])
        self.assertNotIn("wm", resolved["units"])

    def test_external_unit_keeps_links_and_app_but_no_package_or_setup(self):
        dotbot = json.loads(self.work["dotbot.json"])
        resolved = json.loads(self.work["resolved.json"])
        links = [d["link"] for d in dotbot if "link" in d][0]
        commands = [s["command"] for d in dotbot if "shell" in d for s in d["shell"]]
        self.assertNotIn('cask "browser"', self.work["Brewfile"])
        self.assertIn("${XDG_CONFIG_HOME}/browser", links)
        self.assertFalse(any("browser --setup" in c for c in commands))
        self.assertEqual(resolved["units"]["browser"]["state"], "external")
        self.assertEqual(resolved["units"]["browser"]["app"]["leader"], "b")

    def test_setup_steps_follow_dependency_order_and_are_guarded(self):
        dotbot = json.loads(self.home["dotbot.json"])
        commands = [s["command"] for d in dotbot if "shell" in d for s in d["shell"]]
        wm = [i for i, c in enumerate(commands) if "wm --reload" in c][0]
        bar = [i for i, c in enumerate(commands) if "restart bar" in c][0]
        term = [i for i, c in enumerate(commands) if "term --init" in c][0]
        self.assertLess(max(wm, bar), term)
        guarded = [c for c in commands if "term --init" in c][0]
        self.assertTrue(guarded.startswith("if command -v term >/dev/null 2>&1; then"))
        self.assertIn('echo "skip term: needs term"', guarded)

    def test_taps_are_emitted_only_when_used(self):
        self.assertIn('tap "acme/tap", trusted: true', self.home["Brewfile"])

    def test_env_files_carry_profile_values(self):
        self.assertIn('export REPOS_DIR="$HOME/repos"', self.work["env.sh"])
        self.assertIn('export NOTES_DIR="$HOME/notes"', self.work["env.zsh"])

    def test_render_is_deterministic(self):
        m = manifest()
        self.assertEqual(mf.render_all(m), mf.render_all(m))

    def test_comparison_lists_only_differing_units(self):
        text = mf.comparison(manifest())
        self.assertIn("| browser", text)
        self.assertNotIn("| fd ", text)


class AerospaceTest(unittest.TestCase):
    def test_rules_cover_workspace_floating_and_both(self):
        units = {
            "a": {"app": {"bundle_id": "x.a", "workspace": "A"}},
            "b": {"app": {"bundle_id": "x.b", "floating": True}},
            "c": {"app": {"bundle_id": "x.c", "workspace": "9", "floating": True}},
            "d": {"module": "core"},
        }
        text = "\n".join(mf.aerospace_rules(units, ["c", "b", "a", "d"]))
        self.assertIn('if.app-id = "x.a"\nrun = "move-node-to-workspace A"', text)
        self.assertIn('if.app-id = "x.b"\nrun = "layout floating"', text)
        self.assertIn("run = ['layout floating', 'move-node-to-workspace 9']", text)
        self.assertLess(text.index("x.a"), text.index("x.b"))
        self.assertNotIn("# d", text)

    def test_off_unit_gets_no_rule(self):
        units = mf.all_units(manifest(**{"units__music__app__workspace": "M"}))
        states = mf.resolve(manifest(), "work")[0]
        on = [n for n, st in states.items() if st != "off"]
        text = "\n".join(mf.aerospace_rules(units, on))
        self.assertIn("com.acme.term", text)
        self.assertNotIn("com.acme.music", text)

    def test_block_replacement_keeps_the_rest(self):
        tpl = "a = 1\n# BEGIN manifest: window rules\n# note\nold\n# END manifest: window rules\nz = 2"
        out = mf.with_rules(tpl, ["", "new"])
        self.assertEqual(out, "a = 1\n# BEGIN manifest: window rules\n# note\n\nnew\n# END manifest: window rules\nz = 2")


class CanonicalTest(unittest.TestCase):
    def test_canonical_sorts_units_and_orders_keys(self):
        m = manifest()
        m["units"] = {"zz": {"requires": [], "module": "core"}, "aa": {"module": "core"}}
        c = mf.canonical(m)
        self.assertEqual(list(c["units"]), ["aa", "zz"])
        self.assertEqual(list(c["units"]["zz"]), ["module", "requires"])


if __name__ == "__main__":
    unittest.main()
