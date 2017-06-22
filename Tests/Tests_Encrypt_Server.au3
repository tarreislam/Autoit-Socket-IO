#AutoIt3Wrapper_Change2CUI=Y
#include "..\socketIO.au3"
#include <../Packages/Autoit-Unittester/UnitTester.au3>


;Start server
Global $socket = _Io_Listen(8080)
_Io_EnableEncryption("key.txt")
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
	_Io_Emit($socket, "welcome message", $CmdLine[1])
EndFunc   ;==>callback_ClientConnected


Func callback_ClientDisconnected(ByRef $socket)
	Exit
EndFunc   ;==>callback_ClientDisconnected

