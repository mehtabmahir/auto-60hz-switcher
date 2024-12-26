#Persistent
SetTimer, CheckBrowser, 500 ; Check every 1 seconds
currentRefreshRate := 120 ; Assume you start at 120Hz
lastPowerStatus := -1 ; Initialize with an invalid value
cooldown := false ; Add a cooldown to prevent quick switching
cooldownStart := 0
cooldownDuration := 500 ; 1-second cooldown
return

CheckBrowser:
    ; Check if the laptop is plugged in
    VarSetCapacity(powerstatus, 1+1+1+1+4+4)
    success := DllCall("kernel32.dll\GetSystemPowerStatus", "Ptr", &powerstatus)
    AC_status := NumGet(powerstatus, 0, "UChar")

    powerChanged := (AC_status != lastPowerStatus)
    justUnplugged := (lastPowerStatus == 1 && AC_status == 0)
    lastPowerStatus := AC_status

    ; Check if the active window is in fullscreen
    fullscreenDetected := false
    SysGet, screenWidth, 78
    SysGet, screenHeight, 79
    WinGet, winID, ID, A ; Get active window ID
    if winID
    {
        WinGetPos, winX, winY, winWidth, winHeight, ahk_id %winID%
        if (winWidth = screenWidth && winHeight = screenHeight)
        {
            fullscreenDetected := true
        }
    }

    ; If within cooldown, skip refresh rate changes
    if (cooldown && (A_TickCount - cooldownStart < cooldownDuration))
        return

    ; Determine the target refresh rate
    targetRefreshRate := (fullscreenDetected && AC_status == 0) ? 60 : 120

    ; Change refresh rate if needed
    if (currentRefreshRate != targetRefreshRate || justUnplugged)
    {
        Run, nircmd.exe setdisplay 2880 1800 32 %targetRefreshRate%
        currentRefreshRate := targetRefreshRate

        ; If switching to 60Hz, start the cooldown
        if (targetRefreshRate == 60)
        {
            cooldown := true
            cooldownStart := A_TickCount
        }
        else
        {
            cooldown := false
        }
    }

return
