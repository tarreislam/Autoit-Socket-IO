#AutoIt3Wrapper_Change2CUI=Y
#include "..\socketIO.au3"
#include <../Dependencies/Autoit-Unittester/UnitTester.au3>

; Set UT namespace to match our testcase
_UT_SetNamespace("public api")


;Start server
Global $socket = _Io_Listen(8080)
If @error Then
	Exit
EndIf

; -------------
;	All events are registered here
; -------------

_Io_on("connection", callback_ClientConnected)
_Io_on("disconnect", callback_ClientDisconnected)

; Start main loop
While _Io_Loop($socket)
WEnd

; -------------
;	All event callbacks are defined here
; -------------

Func callback_ClientConnected(ByRef $socket)
	; Emit message

	If $CmdLine[2] == "broadcast" Then
		_Io_Broadcast($socket, "welcome message", 1)
	ElseIf $CmdLine[2] == "broadcast to all" Then
		_Io_BroadcastToAll($socket, "welcome message", 1)
	EndIf

	; Quit when the tester tells us were done
	If _Io_getSocketsCount() >= $CmdLine[1] Then Exit
EndFunc   ;==>callback_ClientConnected


Func callback_ClientDisconnected(ByRef $socket)
EndFunc   ;==>callback_ClientDisconnected

