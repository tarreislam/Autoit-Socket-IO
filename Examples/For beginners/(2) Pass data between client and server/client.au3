; Make this an console application
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Run_After=start cmd /c client.exe
; Include SocketIO
#include "..\..\..\socketIO.au3"

; Start the server on port 1000
Global $socket = _Io_Connect(@IPAddress1, 1000)

; Include all events
#include "clientEvents.au3"

; Make sure we are compiled
If Not @Compiled Then
	Exit MsgBox(64, "", "Please compile before running. Tools -> Build")
EndIf

If @error Then
	ConsoleWrite("Failed to connect to port 1000" & @LF)
Else
	ConsoleWrite("Successfully connected to port 1000" & @LF)
EndIf

; Main loop
While _Io_Loop($socket)
WEnd