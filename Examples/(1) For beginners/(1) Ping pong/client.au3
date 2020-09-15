; Make this an console application
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Run_After=start cmd /c client.exe
; Include IO core + the features we want to use for the client
#include "..\..\..\socketIO-Core.au3"
#include "..\..\..\Features\_Io_Emit.au3"
#include "..\..\..\Features\_Io_Debug.au3"

; Connect to server
Global $socket = _Io_connect(@IPAddress1, 1000)
If Not $socket Then
	MsgBox(64, "Failed to connect to server", "Failed to connect to server, is the server running?")
	Exit
EndIf

;_Io_DevDebug(); Uncomment to attach deubber

; bind events
_Io_On('ping'); _On_ping

; Main loop
While _Io_Loop($socket)
WEnd


#Region Io events
Func _On_Ping(Const $socket)
	ConsoleWrite("CLIENT: PING" & @LF)
	Sleep(1000); ONly for demonstration.
	_Io_Emit($socket, 'ping')
EndFunc
#EndRegion