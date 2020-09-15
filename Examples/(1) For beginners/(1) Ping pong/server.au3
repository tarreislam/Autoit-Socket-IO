; Make this an console application
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Run_After=start cmd /c server.exe
; Include IO core + the features we want to use for the server
#include "..\..\..\socketIO-Core.au3"
#include "..\..\..\Features\_Io_Emit.au3"
#include "..\..\..\Features\_Io_Debug.au3"

; Define some resources
Global $userList = ObjCreate("Scripting.Dictionary")

; Attempt to listen on port 1000
Global $socket = _Io_listen(1000)

If Not $socket Then
	MsgBox(64, "Failed to start server", "Failed to listen on port 1000. Is it already listening?")
	Exit
EndIf

;_Io_DevDebug() ; Uncomment to attach deubber

; Bind events
_Io_On('connection'); _On_connection
_Io_On('disconnect'); _On_disconnect
_Io_On('ping'); _On_ping


; Main loop
While _Io_Loop($socket)
WEnd


#Region Io events

Func _On_connection(Const $socket)
	ConsoleWrite("Someone connected" & @LF)

	; Here we will send the event "ping" to our client.
	_Io_Emit($socket, 'ping')
EndFunc

Func _On_disconnect(Const $socket)
	ConsoleWrite("Someone disconnected" & @LF)
EndFunc

Func _On_ping(Const $socket)
	; Client sent us an PONG
	ConsoleWrite("SERVER: PONG" & @LF)
	Sleep(1000); ONly for demonstration.
	; We respond with a ping
	_Io_Emit($socket, 'ping')
EndFunc

#EndRegion