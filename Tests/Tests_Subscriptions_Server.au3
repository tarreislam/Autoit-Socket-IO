#AutoIt3Wrapper_Change2CUI=Y
#include "..\socketIO.au3"
#include <../Dependencies/Autoit-Unittester/UnitTester.au3>


_UT_SetNamespace("public api")


;Start server
Global $socket = _Io_Listen(8080)

; -------------
;	All events are registered here
; -------------

_Io_on("connection", callback_ClientConnected)


; Start main loop
While _Io_Loop($socket)
WEnd

; -------------
;	All event callbacks are defined here
; -------------

Func callback_ClientConnected(ByRef $socket)
	Local $iSocketsCount =  _Io_getSocketsCount()

	; Join client to rooms
	if $iSocketsCount <= 2 Then
		_Io_Subscribe($socket, "Room A")
		ConsoleWrite("Joining socket to Room A" & @CRLF)
	Else
		_Io_Subscribe($socket, "Room B")
		ConsoleWrite("Joining socket to Room B" & @CRLF)
	EndIf

	If $iSocketsCount == 4 Then
		_Io_BroadcastToRoom($socket, "Room A", "welcome message", "Hello from Room A")
		_Io_BroadcastToRoom($socket, "Room B", "welcome message", "Hello from Room B")
		ConsoleWrite("Broadcasting to rooms" & @CRLF)
		_Io_Disconnect()
	EndIf




EndFunc   ;==>callback_ClientConnected


