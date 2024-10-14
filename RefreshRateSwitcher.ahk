#Persistent
SetTimer, CheckBrowser, 1000  ; Check every 1 second
currentRefreshRate := 120     ; Assume you start at 120Hz
youtubeTabOpen := false       ; Track if YouTube tab is open
lastYouTubeTime := 0          ; Time when YouTube was last detected
return

CheckBrowser:
    previousYouTubeState := youtubeTabOpen
    youtubeTabOpen := false

    ; Check for YouTube in Chrome
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

    ; Check for YouTube in Edge
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

    ; Set refresh rate to 60Hz if YouTube is open
    if (youtubeTabOpen)
    {
        if (currentRefreshRate != 60)
        {
            Run, nircmd.exe setdisplay 2880 1800 32 60
            currentRefreshRate := 60
        }
        lastYouTubeTime := A_TickCount
    }
    ; Set refresh rate to 120Hz if YouTube is closed
    else if (currentRefreshRate != 120)
    {
        ; If YouTube was open in the previous check but not now, it means it was just closed
        if (previousYouTubeState)
        {
            Run, nircmd.exe setdisplay 2880 1800 32 120
            currentRefreshRate := 120
        }
        ; If YouTube has been closed for more than 10 seconds, switch back to 120Hz
        else if (A_TickCount - lastYouTubeTime > 10000)
        {
            Run, nircmd.exe setdisplay 2880 1800 32 120
            currentRefreshRate := 120
        }
    }

return