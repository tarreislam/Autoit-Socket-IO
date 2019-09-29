#AutoIt3Wrapper_Change2CUI=Y
#include "..\..\..\socketIO.au3"


;Start server
Global $socket = _Io_Listen(8080)

If Not @error Then
	ConsoleWrite("Listening on port 8080" & @CRLF)
	ConsoleWrite("Press F1 to remove ban on " & @IPAddress1)
Else
	ConsoleWrite("Failed to open socket:" & @error & @CRLF)
	Exit
EndIf

; -------------
;	All events are registered here
; -------------

_Io_on("connection", callback_ClientConnected)
_Io_on("disconnect", callback_ClientDisconnected)


HotKeySet("{f1}", "remove_ban")

; Start main loop
While _Io_Loop($socket)
WEnd

Func callback_ClientConnected(ByRef $socket)
	ConsoleWrite("Client connected" & @LF)

	_Io_Emit($socket, "welcome message", "Welcome to moonside welcom to de mon side moon")

	; Ban if not banned
	if Not _Io_isBanned($socket) Then _Io_Ban($socket, 60, "Bad behaviour")

EndFunc

Func callback_ClientDisconnected(ByRef $socket)
	ConsoleWrite("Client Disconnected" & @LF)
EndFunc






Func remove_ban()
	_Io_Sanction(@IPAddress1)
	ConsoleWrite("Removed ban for " & @IPAddress1 & @LF)
EndFunc