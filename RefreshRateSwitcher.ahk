#Persistent
SetTimer, CheckBrowser, 1000 ; Check every 1 second
currentRefreshRate := 120 ; Assume you start at 120Hz
lastPowerStatus := -1 ; Initialize with an invalid value
cooldown := false ; Add a cooldown to prevent quick switching
cooldownStart := 0
cooldownDuration := 1000 ; 1-second cooldown
return

CheckBrowser:
    ; Check if the laptop is plugged in
    if (!VarSetCapacity(powerstatus, 1+1+1+1+4+4) || !DllCall("kernel32.dll\GetSystemPowerStatus", "Ptr", &powerstatus))
        return ; Exit if power status can't be retrieved
    AC_status := NumGet(powerstatus, 0, "UChar")

    ; Skip if power state hasn't changed and within cooldown
    if (AC_status == lastPowerStatus && cooldown && (A_TickCount - cooldownStart < cooldownDuration))
        return
    lastPowerStatus := AC_status

    ; Detect fullscreen state of the active window
    fullscreenDetected := false
    SysGet, screenWidth, 78
    SysGet, screenHeight, 79
    WinGet, winID, ID, A ; Get active window ID

    if winID
    {
        WinGetPos, winX, winY, winWidth, winHeight, ahk_id %winID%
        WinGetClass, winClass, ahk_id %winID%
        WinGetTitle, winTitle, ahk_id %winID%

        ; Exclude the desktop and Alt+Tab interface
        if (winWidth = screenWidth && winHeight = screenHeight && winClass != "WorkerW" && winClass != "Progman" && winTitle != "Task Switching")
        {
            fullscreenDetected := true
        }
    }

    ; Determine the target refresh rate
    targetRefreshRate := (fullscreenDetected && AC_status == 0) ? 60 : 120

    ; Change refresh rate if needed
    if (currentRefreshRate != targetRefreshRate)
    {
        Run, nircmd.exe setdisplay 2880 1800 32 %targetRefreshRate%
        currentRefreshRate := targetRefreshRate

        ; Start cooldown if switching to 60Hz
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
