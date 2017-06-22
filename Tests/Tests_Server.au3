#AutoIt3Wrapper_Change2CUI=Y
#include "..\socketIO.au3"
#include <../Packages/Autoit-Unittester/UnitTester.au3>

; Set UT namespace to match our testcase
_UT_SetNamespace("public api")

_UT_Set("@server client connected to server", False)
_UT_Set("@server client disconnected from server", False)
_UT_Set("@server server recvd message from client", False)

;Start server
Global $socket = _Io_Listen(8080)
If @error Then
	_UT_Set("@server server started", False)
	Exit
Else
	_UT_Set("@server server started", True)
EndIf

; -------------
;	All events are registered here
; -------------

_Io_on("connection", callback_ClientConnected)
_Io_on("disconnect", callback_ClientDisconnected)
_Io_on("message from client", callback_ClientSentAnMessage)

; Start main loop
While _Io_Loop($socket)
WEnd

; -------------
;	All event callbacks are defined here
; -------------

Func callback_ClientConnected(ByRef $socket)
	_UT_Set("@server client connected to server", True)
	; Emit message
	_Io_Emit($socket, "welcome message", $CmdLine[1])
EndFunc   ;==>callback_ClientConnected


Func callback_ClientDisconnected(ByRef $socket)
	_UT_Set("@server client disconnected from server", True)
	Exit
EndFunc   ;==>callback_ClientDisconnected


Func callback_ClientSentAnMessage(ByRef $socket, $message)
	_UT_Set("@server server recvd message from client", True)
	Sleep(5000)
	Exit
EndFunc   ;==>callback_ClientSentAnMessage
