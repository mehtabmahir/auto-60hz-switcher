#Persistent
SetTimer, CheckBrowser, 2000 ; Check every 2 seconds
currentRefreshRate := 120 ; Assume you start at 120Hz
youtubeTabOpen := false ; Track if YouTube tab is open
lastYouTubeTime := 0 ; Time when YouTube was last detected
lastPowerStatus := -1 ; Initialize with an invalid value
cooldown := false ; Add a cooldown to prevent quick switching
cooldownStart := 0
cooldownDuration := 2000 ; 2 second cooldown
return

CheckBrowser:
    ; Check if the laptop is plugged in
    VarSetCapacity(powerstatus, 1+1+1+1+4+4)
    success := DllCall("kernel32.dll\GetSystemPowerStatus", "Ptr", &powerstatus)
    AC_status := NumGet(powerstatus, 0, "UChar")

    powerChanged := (AC_status != lastPowerStatus)
    justUnplugged := (lastPowerStatus == 1 && AC_status == 0)
    lastPowerStatus := AC_status

    previousYouTubeState := youtubeTabOpen
    youtubeTabOpen := false

    ; Determine if a YouTube tab is open (first Chrome, then Edge)
    if WinExist("ahk_class Chrome_WidgetWin_1")
    {
        WinGet, chromeList, List, ahk_class Chrome_WidgetWin_1
        Loop, %chromeList%
        {
            thisChrome := chromeList%A_Index%
            WinGetTitle, chromeTitle, ahk_id %thisChrome%
            if (InStr(chromeTitle, "YouTube"))
            {
                youtubeTabOpen := true
                break
            }
        }
    }

    if (!youtubeTabOpen && WinExist("ahk_class ApplicationFrameWindow"))
    {
        WinGet, edgeList, List, ahk_class ApplicationFrameWindow
        Loop, %edgeList%
        {
            thisEdge := edgeList%A_Index%
            WinGetTitle, edgeTitle, ahk_id %thisEdge%
            if (InStr(edgeTitle, "YouTube"))
            {
                youtubeTabOpen := true
                break
            }
        }
    }

    ; If within cooldown, skip refresh rate changes
    if (cooldown && (A_TickCount - cooldownStart < cooldownDuration))
        return

    ; Determine the target refresh rate
    targetRefreshRate := (youtubeTabOpen && AC_status == 0) ? 60 : 120

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

    ; Update last YouTube time if applicable
    if (youtubeTabOpen)
    {
        lastYouTubeTime := A_TickCount
    }

return
