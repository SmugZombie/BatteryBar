#SingleInstance force

#Include lib.ahk
OnMessage(0x203, "WM_LBUTTONDBLCLK")
OnMessage(0x204, "WM_RBUTTONDOWN")
SysGet, Mon1, Monitor, 1 
MyDimensions := 80
MyHeight := (A_ScreenHeight - 10 - 50)
MyWidth := (Mon1Right - MyDimensions - 10)
IniRead, MyHeight, battery.ini, Options, MyHeight, %MyHeight%
IniRead, MyWidth, battery.ini, Options, MyWidth, %MyWidth%

Menu, Tray, Icon, images\battery.ico
Menu, Tray, Tip, Battery Status

Menu, BatteryBar, Add, Reload, GuiReload
Menu, BatteryBar, Add
Menu, BatteryBar, Add, Exit, GuiClose

charging := False
battery := 0

GUI:
	Temp := "--"
	Gui +LastFound +AlwaysOnTop +ToolWindow -Caption
	Gui, Color, EEAA99
	Gui, Add, Picture, x0 y0 h27 w78 vGuiBack, images\100.png
	Gui, Add, Picture, x63 y4 vCharging, 
	WinSet, TransColor, EEAA99
	Gui, Show, Center w78 h27 x%MyWidth% y%MyHeight%, AHK Battery Percent
	hwnd:=winexist()
	
	Loop
	{
		BatteryStatus := GetBatteryStatus()
		
		If (BatteryStatus.acLineStatus == 0)
		{
			;Gui, Font, s14 w700 cRed, Arial
			if(charging = True){
				GuiControl, -Redraw,     Charging
		    	;GuiControl,,             Charging, images\charging.png
		    	;GuiControl, +Redraw,    Charging
		    	charging := False
			}
		}
		Else
		{
			;Gui, Font,  s14 w700 cGreen, Arial
			if(charging = False){
				GuiControl, -Redraw,     Charging
		    	GuiControl,,             Charging, images\charging.png
		    	GuiControl, +Redraw,    Charging
		    	charging := True
			}
		}
		
		;GuiControl, Font, GuiAcLineStatus
		GuiControl, , GuiAcLineStatus, %Temp%

		; 0 15 25 30 40 50 60 70 80 90 100
		
		Temp := BatteryStatus.batteryLifePercent
		If (Temp == 255)
		{
			Temp := "?"
		}
		Else
		{
			prevTemp := battery
			if(Temp != prevTemp)
			{
				;Temp = %Temp%`%
				GuiControl, -Redraw,     GuiBack
				if(Temp >= 95){
					GuiControl,,GuiBack, images\100.png
				}
				else if(Temp >= 85){
					GuiControl,,GuiBack, images\90.png
				}
				else if(Temp >= 75){
					GuiControl,,GuiBack, images\80.png
				}
				else if(Temp >= 65){
					GuiControl,,GuiBack, images\70.png
				}
				else if(Temp >= 55){
					GuiControl,,GuiBack, images\60.png
				}
				else if(Temp >= 45){
					GuiControl,,GuiBack, images\50.png
				}
				else if(Temp >= 35){
					GuiControl,,GuiBack, images\40.png
				}
				else if(Temp >= 25){
					GuiControl,,GuiBack, images\30.png
				}
				else if(Temp >= 20){
					GuiControl,,GuiBack, images\25.png
				}
				else if(Temp >= 10){
					GuiControl,,GuiBack, images\15.png
				}
				else if(Temp >= 0){
					GuiControl,,GuiBack, images\0.png
				}
				GuiControl, +Redraw,    GuiBack
			}
		}
		
		GuiControl, , GuiBatteryPercent, %Temp%
		winset,alwaysontop,off,ahk_id %hwnd%
		winset,alwaysontop,on,ahk_id %hwnd%
		Sleep, 1500
	}
Return

WM_LBUTTONDBLCLK(wParam, lParam)
{
    X := lParam & 0xFFFF
    Y := lParam >> 16
    ; Ensure within proper range to allow dragging window
	if (x>0 and x<78 and y>0 and y<27){
		PostMessage, 0xA1, 2,,, A 
		sleep 500
		WinGetPos,x,y,w,h,a
		; Save to ini to autoload here next time
		SaveCoords(x,y)
	}
}

SaveCoords(myx,myy)
{
	IniWrite, %myy%, battery.ini, Options, MyHeight
	IniWrite, %myx%, battery.ini, Options, MyWidth
}

WM_RBUTTONDOWN()
{
	Menu, BatteryBar, Show
}

GuiClose:
	ExitApp
Return

GuiReload:
	Reload
Return