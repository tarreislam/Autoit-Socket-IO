#AutoIt3Wrapper_Change2CUI=Y
#include "..\..\..\socketIO.au3"

;Start server
Global $socket = _Io_Listen(8080)

If Not @error Then
	ConsoleWrite("Listening on port 8080" & @CRLF)
Else
	ConsoleWrite("Failed to open socket:" & @error & @CRLF)
	Exit
EndIf

; -------------
;	All events are registered here
; -------------

_Io_on("connection", callback_ClientConnected)
_Io_on("disconnect", callback_ClientDisconnected)
_Io_on("message from client", callback_ClientSentAnMessage)

_Io_DevDebug(
; Start main loop
While _Io_Loop($socket)
WEnd

; -------------
;	All event callbacks are defined here
; -------------

Func callback_ClientConnected(ByRef $socket)
	ConsoleWrite("Sending a welcome message" & @CRLF)

	_Io_socketSetProperty($socket, 'test', 123)

	_Io_Emit($socket, "welcome message", "This is SocketIo for autoit")
EndFunc   ;==>callback_ClientConnected


Func callback_ClientDisconnected(ByRef $socket)
	Local $extendedInfo = _Io_socketGetProperty($socket)
	ConsoleWrite(@CRLF & "Client " & @CRLF & "IP: " & $extendedInfo[1] & @CRLF & "Date connected " & $extendedInfo[2] & @CRLF & "Has disonnected from the server" & @CRLF)
EndFunc   ;==>callback_ClientDisconnected


Func callback_ClientSentAnMessage(ByRef $socket, $message)
	ConsoleWrite("Client sent an message: " & $message & @CRLF & @CRLF & "Closing server in 5 sec")
	Sleep(5000)
	Exit
EndFunc   ;==>callback_ClientSentAnMessage
