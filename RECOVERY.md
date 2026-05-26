# RECOVERY.md

What to do if the keyboard is wedged and the lock screen won't accept input. Read this from your phone — that's the
whole point.

## TL;DR

| Severity                   | First move                                       |
| -------------------------- | ------------------------------------------------ |
| Keyboard partially works   | Reboot to log in, then SSH in for surgery        |
| Keyboard fully wedged      | SSH from phone (Section 1)                       |
| SSH refused, screen locked | Long-press power → Recovery mode (Section 2)     |
| Recovery mode also flakes  | DFU + reinstall macOS (last resort, not covered) |

## 1. SSH from phone (primary path)

This Mac has Remote Login enabled by default (`scripts/setup/setup-macos` runs `sudo systemsetup -setremotelogin on`).
That means a frozen keyboard does **not** stop you from getting in — as long as the Mac is awake and on the LAN.

### Prep (do this once, BEFORE you need it)

1. Install an SSH client on your phone:
   - iOS: **Termius** (free tier), **Blink Shell**
   - Android: **Termux**, **JuiceSSH**
2. Find the Mac's LAN IP and write it on a sticky note:

   ```sh
   ipconfig getifaddr en0          # Wi-Fi
   ipconfig getifaddr en1          # Wired (Thunderbolt/Ethernet)
   ```

   …or System Settings → Wi-Fi → Details → IP address.

3. Confirm SSH works from the phone right now:

   ```sh
   ssh <username>@<lan-ip>
   ```

   If the connection refuses, see "SSH isn't working" below.

### In an emergency

From the phone, SSH in and run:

```sh
# 1. Stop kanata immediately (frees keyboard pipeline)
sudo launchctl bootout system/com.jtroo.kanata
sudo launchctl bootout system/com.jtroo.kanata-watcher

# 2. (If kanata is no longer the suspect) try Hammerspoon
osascript -e 'tell application "Hammerspoon" to quit'
# or, more forcefully:
pkill -x Hammerspoon

# 3. Deactivate the Karabiner DriverKit dext (the root cause of the
#    Tahoe freeze incidents)
sudo "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/scripts/uninstall/deactivate_driver.sh"

# 4. Confirm no kernel keyboard wedges remain
systemextensionsctl list | grep -i karabiner   # expect: empty
pgrep -f kanata                                # expect: empty

# 5. Reboot fresh
sudo shutdown -r now
```

After step 5, log back in — keyboard input should work without any third-party remapper. From there you can decide
whether to bring Hammerspoon back up (`open -a Hammerspoon`) or leave it off for diagnosis.

### SSH isn't working

| Symptom                                       | Fix                                                                                 |
| --------------------------------------------- | ----------------------------------------------------------------------------------- |
| `ssh: connect to host …: Operation timed out` | Mac is asleep. Wake it: short-press power button (no keyboard needed)               |
| `ssh: connect to host …: Connection refused`  | Remote Login disabled. From the Mac directly: `sudo systemsetup -setremotelogin on` |
| `Permission denied (publickey,password)`      | Wrong username, or no public key. Re-check `~/.ssh/authorized_keys` on the Mac      |
| LAN IP changed                                | Router probably handed out a new lease. Use Bonjour: `ssh <hostname>.local`         |

## 2. Recovery mode (fallback when SSH is also down)

Recovery mode boots a clean macOS environment with no third-party kexts or dexts. The Mac's own keyboard works in
Recovery because no Karabiner-DriverKit / kanata exists at this layer.

### Boot into Recovery (Apple Silicon)

1. Power off the Mac. Hold the power button (Touch ID button on laptops) until you see "Loading startup options…".
   **Hardware button only — no keyboard required.**
2. Click Options → Continue. Authenticate with your user.
3. Open Utilities → Terminal.

### What to run in Recovery

You're now in a pre-boot shell with your data volume mounted at `/Volumes/<your-data-volume>` (often
`Macintosh HD - Data`).

```sh
# Deactivate the Karabiner dext from outside the live system
sudo "/Volumes/Macintosh HD - Data/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/scripts/uninstall/deactivate_driver.sh"

# Remove kanata daemon plists so it doesn't reload on next boot
sudo rm -f /Volumes/Macintosh\ HD/Library/LaunchDaemons/com.jtroo.kanata*.plist
```

Then Apple Menu → Restart → boot into normal macOS.

## 3. Karabiner / kanata uninstall (run from anywhere)

The two killer commands for fully removing the Tahoe-incompatible stack:

```sh
# Tear down the DriverKit extension
sudo "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/scripts/uninstall/deactivate_driver.sh"

# Uninstall Karabiner-Elements user binary
sudo "/Library/Application Support/org.pqrs/Karabiner-Elements/uninstall.sh"
```

The full repo-side decommission lives in `scripts/migrate/decommission-kanata-karabiner` (added in Phase 3 of the
Hammerspoon migration). That script is idempotent and safe to re-run from SSH or local terminal.

## 4. State-aware warnings

### During the migration (Phase 1 or Phase 2)

The `kanata-keyboard-watcher` LaunchDaemon kickstarts the kanata daemon on **every** HID change. With the Tahoe-broken
Karabiner dext still loaded, this means **plugging in a wired USB keyboard does NOT guarantee input** — the dext can
wedge IOHID for the entire system, including the new device. Verified: a wired Nuphy was also locked out during a
previous incident.

**The only reliable escape during this window is SSH-from-phone.**

### After Phase 3 (kanata + Karabiner fully removed)

Hammerspoon is userspace. If it ever wedges, the absolute worst case is:

```sh
pkill -x Hammerspoon
```

and you're back to a raw, unmapped keyboard. No reboot needed. No kernel involvement. The dext-induced freeze mode is
gone for good.

## 5. Verifying recovery readiness

Run these locally (not from the phone) any time after `./install`:

```sh
# SSH listening on port 22?
sudo systemsetup -getremotelogin
sudo lsof -iTCP:22 -sTCP:LISTEN

# Mac is reachable from the phone? (from the phone, replace IP)
ssh -o ConnectTimeout=5 <username>@<lan-ip> 'echo ok'
```

If any of these fail, fix BEFORE you need this document for real.
