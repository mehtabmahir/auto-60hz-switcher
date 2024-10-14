#Persistent
SetTimer, CheckBrowser, 1000  ; Check every 1 second
currentRefreshRate := 120     ; Assume you start at 120Hz
return

CheckBrowser:
    ; For Google Chrome playing a YouTube video
    IfWinActive, ahk_class Chrome_WidgetWin_1
    {
        ; Check if the active window is YouTube
        WinGetTitle, Title, A
        if (InStr(Title, "YouTube") and currentRefreshRate != 60)  ; Only switch if refresh rate is not already 60Hz
        {
            Run, nircmd.exe setdisplay 2880 1800 32 60
            currentRefreshRate := 60
        }
        lastBrowserTime := A_TickCount
    }
    ; For Microsoft Edge playing a YouTube video
    else IfWinActive, ahk_class ApplicationFrameWindow
    {
        ; Check if the active window is YouTube
        WinGetTitle, Title, A
        if (InStr(Title, "YouTube") and currentRefreshRate != 60)  ; Only switch if refresh rate is not already 60Hz
        {
            Run, nircmd.exe setdisplay 2880 1800 32 60
            currentRefreshRate := 60
        }
        lastBrowserTime := A_TickCount
    }
    ; If neither browser is active and 5 seconds have passed since the last browser check, revert to 120Hz
    else
    {
        if (currentRefreshRate != 120 && (A_TickCount - lastBrowserTime > 5000))  ; 5-second delay
        {
            Run, nircmd.exe setdisplay 2880 1800 32 120
            currentRefreshRate := 120
        }
    }
return
