# WoW OBS Auto Recorder
This repo contains an Autohotkey script that allows you to
automatically record boss pulls in World of Warcraft.

# Table of Contents  
[Requirements](#requirements)  
[Explanation](#explanation)  
[Setup](#setup)  
[**Usage**](#usage)  
[FAQ](#faq)

## Requirements
- Windows
- World of Warcraft
- [BigWigs](https://github.com/BigWigsMods/BigWigs/releases) or
  [DBM](https://www.curseforge.com/wow/addons/deadly-boss-mods)
- [WeakAuras](https://github.com/WeakAuras/WeakAuras2/releases)
    + [Auto Recording WA](https://wago.io/5fxvRKT0U)
- [AutoHotkey](https://github.com/Lexikos/AutoHotkey_L/releases)
  (v1.1.21.00 or newer)
- [OBS](https://github.com/obsproject/obs-studio/releases) (26.1.1 64
  bit, will likely work with newer too)

## Explanation
The difficulty in automatically recording pulls in World of Warcraft
comes from the lack of an interface between in-game events and
Windows. To get around this, we can draw pixels in-game, which we then
read back out in Windows.

This setup contains a WeakAura that will draw a pixel in the top-left
corner of the game. The WA will then listen to pull count timers from
BigWigs or DBM and update the color of the pixel when combat is about
to begin / has begun / has ended.

The Autohotkey script will take care of reading this pixel, and
sending keystrokes to OBS in order to start / stop the recording.

## Setup

### Keybinds
Before getting started, you will have to register the following
keybinds in OBS:
- Start Recording <kbd>ALT</kbd> + <kbd>F11</kbd>
- Stop Recording <kbd>ALT</kbd> + <kbd>F12</kbd>

These are the default keybinds expected by the AHK script. These can
be changed by updating the script.

### Local recording
Since this setup will make use of OBS's recording feature, you might
have to configure that as well. These settings are found under:
- `Settings → Output → Recording`
- `Settings → Advanced → Recording`

For an easier time organizing and mapping between recordings and WCL
log entries, use a custom filename format, such as:
- `[%YY-%MM-%DD] %hh %mm`

The `%hh %mm` part will match the timestamp on WCL entries.

**Note** — These files _quickly_ add up over time, so make sure you're
recording to a disk with plenty of space, and avoid recording in
unnecessarily high quality. The settings I'm using are:

- **Recording Quality**: High Quality, Medium File Size
- **Recording Format**: mp4
- **Encoder**: Hardware (NVENC)
- **Resolution**: 2560x1440
- **FPS**: 30

This ends up being roughly 112MB per minute of footage. A night of 25
pulls on a 3min progression fight requires roughly 8.5GB of space.

## Usage
- Import the [Auto Recording](https://wago.io/5fxvRKT0U) WeakAura
- Start OBS
- Start [`wow-auto-recorder.ahk`](https://raw.githubusercontent.com/drnoonien/wow-obs-auto-recorder/master/wow-auto-recorder.ahk) (download it and double-click to run)
- Start a pull counter `/pull 10`
- Pull the boss

## FAQ

**Q**: Will I get banned for this?  
**A**: No idea, probably, who cares

**Q**: Will it record even without a proper pull count? i.e. ninja pulls?  
**A**: Yes, the WA/AHK script is configured to start recording as soon
as it detects a raid encounter starting, the pull count only helps us
to start gracefully 5 seconds before the actual pull

**Q**: What happens if I tab out and lose the tracking pixel?  
**A**: The WA/AHK is setup such that if a recording is active, it will
stay active until it can find a tracking pixel that explicitly tells
it to stop recording -- This is to ensure we don't accidentally stop a
recording mid-combat, or if the user opens his WA options while dead
in combat.

**Q**: Something seems buggy  
**A**: Ok, figure out what you're doing that's causing the bug and
open an issue