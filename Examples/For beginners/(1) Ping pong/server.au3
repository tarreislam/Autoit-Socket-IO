; Make this an console application
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Run_After=start cmd /c server.exe
; Include SocketIO
#include "..\..\..\socketIO.au3"

; Start the server on port 1000
Global $socket = _Io_listen(1000)

; Register all events
#include "serverEvents.au3"

; Make sure we are compiled
If Not @Compiled Then
	Exit MsgBox(64, "", "Please compile before running. Tools -> Build")
EndIf

If @error Then
	ConsoleWrite("Failed to listen on port 1000" & @LF)
Else
	ConsoleWrite("Listening on port 1000 and waiting for client" & @LF)
EndIf

; Main loop
While _Io_Loop($socket)
WEnd