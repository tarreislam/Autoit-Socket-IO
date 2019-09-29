#AutoIt3Wrapper_Change2CUI=Y
#include "..\..\..\socketIO.au3"

; Connect to server
Global $socket = _Io_Connect(@IPAddress1, 8080, True)

If Not @error Then
	ConsoleWrite("Successfully connected to server" & @CRLF)
Else
	ConsoleWrite("Failed to open socket:" & @error & @CRLF)
	Exit
EndIf

; -------------
;	All events are registered here
; -------------

_Io_on("welcome message", callback_serverHasGreetedUs)
_Io_on("disconnect", callback_WeDisconnectedFromServer)

; Start main loop
While _Io_Loop($socket)
WEnd

; -------------
;	All event callbacks are defined here
; -------------

Func callback_serverHasGreetedUs(ByRef $socket, $message)
	MsgBox(0, "The Client", "Message received from server: " & $message & @CRLF & "Press OK to send something back to the server")
	_Io_Emit($socket, "message from client", "Hello from client!")
EndFunc   ;==>callback_serverHasGreetedUs

Func callback_WeDisconnectedFromServer($socket)
	MsgBox(0, "The Client", "Lost connection to server... Aborting!")
	Exit
EndFunc   ;==>callback_WeDisconnectedFromServer
