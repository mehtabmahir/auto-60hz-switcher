#Persistent
SetTimer, CheckBrowser, 1000  ; Check every 1 second
currentRefreshRate := 120     ; Assume you start at 120Hz
youtubeTabOpen := false       ; Track if YouTube tab is open
return

CheckBrowser:
    youtubeTabOpen := false

    ; For Google Chrome
    if WinExist("ahk_class Chrome_WidgetWin_1")
    {
        ControlGet, hwnd, Hwnd,, Chrome_RenderWidgetHostHWND1, ahk_class Chrome_WidgetWin_1
        for tab in ["Google Chrome - YouTube", "ahk_class Chrome_WidgetWin_1"]
        {
            WinActivate, %tab%
            WinGetTitle, Title, A
            if (InStr(Title, "YouTube"))
            {
                youtubeTabOpen := true
                if (currentRefreshRate != 60)
                {
                    Run, nircmd.exe setdisplay 2880 1800 32 60
                    currentRefreshRate := 60
                }
                break
            }
        }
    }

    ; For Microsoft Edge
    if WinExist("ahk_class ApplicationFrameWindow")
    {
        ControlGet, hwnd, Hwnd,, Chrome_RenderWidgetHostHWND1, ahk_class ApplicationFrameWindow
        for tab in ["Microsoft Edge - YouTube", "ahk_class ApplicationFrameWindow"]
        {
            WinActivate, %tab%
            WinGetTitle, Title, A
            if (InStr(Title, "YouTube"))
            {
                youtubeTabOpen := true
                if (currentRefreshRate != 60)
                {
                    Run, nircmd.exe setdisplay 2880 1800 32 60
                    currentRefreshRate := 60
                }
                break
            }
        }
    }

    ; If no YouTube tab is detected and 5 seconds have passed, revert to 120Hz
    if (!youtubeTabOpen && currentRefreshRate != 120 && (A_TickCount - lastBrowserTime > 5000))
    {
        Run, nircmd.exe setdisplay 2880 1800 32 120
        currentRefreshRate := 120
    }

    ; Update the last active time if a YouTube tab is open
    if (youtubeTabOpen)
    {
        lastBrowserTime := A_TickCount
    }

return
