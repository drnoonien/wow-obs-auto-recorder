; ----------------------------------
; GLOBAL SETTINGS - NO TOUCHIE
; ----------------------------------
#NoEnv ; ......................... Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force ; ......... Only one instance of the program will run
#Persistent ; .................... Keeps a script permanently running (that is, until the user closes it or ExitApp is encountered).
SendMode Input ; ................. Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; .... Ensures a consistent starting directory.
SetBatchLines, -1 ; .............. Determines how fast a script will run (affects CPU utilization). -1 is fastest. Set to 10ms in complex scripts.

; We need this for the newer version of OBS to intercept keys
SetKeyDelay, -1, 50

; Coordinates are relative to the active window's client area, which
; excludes the window's title bar, menu (if it has a standard one) and
; borders
CoordMode, Pixel, Client

; ---------------------- PROJECT CODE BELOW ----------------------

global STATE_IDLE := 0
global STATE_PRIMED := 1
global STATE_ACTIVE := 2
global STATE_LOST := -1

global PREV_STATE := STATE_IDLE
global IS_RECORDING := false

; Run the main loop at this tick-rate
SetTimer, MainLoop, 250
return

; ---------------------- AUTO-EXEC SECTION ENDS ----------------------

/*
    Scrapes the screen looking for the state pixel rendered by the
    associated weakaura.

    This function will obviously misbehave if something other than the
    weakaura happens to render a color in the exact spot we're
    looking, but the odds of that happening seems to be nonexistent in
    practice.
*/
getState() {
    PixelGetColor, stateColor, 1, 1, RGB

    if (stateColor == "0x0000FF") {
        return STATE_IDLE
    }

    if (stateColor == "0xFF0000") {
        return STATE_PRIMED
    }

    if (stateColor == "0x00FF00") {
        return STATE_ACTIVE
    }

    return STATE_LOST
}

/*
    Tells OBS to start recording. This function must be idempotent in
    case we end up hammering it multiple times in a short window.
*/
startRecording() {
    if (!IS_RECORDING) {
        SoundBeep, 200
        IS_RECORDING := true

        ; Tested on 26.1.1, sends a hotkey command to the top Window Class
        ControlSend, ahk_parent, !{F11}, ahk_class Qt5152QWindowIcon
    }
}

/*
    Tells OBS to stop recording. This function must be idempotent in
    case we end up hammering it multiple times in a short window.
*/
stopRecording() {
    if (IS_RECORDING) {
        SoundBeep, 150
        IS_RECORDING := false

        ; Tested on 26.1.1, sends a hotkey command to the top Window Class
        ControlSend, ahk_parent, !{F12}, ahk_class Qt5152QWindowIcon
    }
}

/*
    Main application loop. On each tick, we look for the state pixel,
    then figure out what state we should be in.
*/
MainLoop: 
    currentState := getState()

    if (currentState <= STATE_LOST) {

        ; We've lost the tracking pixel, this could be due tabbing
        ; out, what do we do here? It also happens if we hit a
        ; loading-screen mid-fight.
        ;
        ; Do nothing, continue recording until STATE_IDLE is found.

    } else {

        if (currentState == STATE_IDLE) {

            if (PREV_STATE == STATE_ACTIVE) {
                ; The fight ended, stop recording with a grace period
                SetTimer, AsyncStopRecord, -5000
            }

            if (PREV_STATE == STATE_PRIMED) {
                ; Something got canceled, stop recording instantly
                stopRecording()
            }

        }

        if (currentState == STATE_PRIMED) {

            ; This means we went from ACTIVE -> PRIMED, this is an
            ; error state that can occur if the WA misbehaves. We're
            ; going to assume the user stopped the recording manually.
            if (PREV_STATE == STATE_ACTIVE) {
                ; Try stopping the recording in order to set the
                ; script state to something predictable.
                stopRecording()
                ; Sleep for a bit in case OBS is slow to flip
                Sleep, 250
            }

            startRecording()
        }

        if (currentState == STATE_ACTIVE) {
            ; Maintain recording

            if (!IS_RECORDING) {
                startRecording()
            }
        }

        PREV_STATE := currentState

    }

return

/*
    Subroutine alias to trigger the `stopRecording` function.
*/
AsyncStopRecord:
    stopRecording()
return
