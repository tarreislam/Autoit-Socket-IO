#AutoIt3Wrapper_Change2CUI=Y
#include "..\socketIO.au3"
#include <../Dependencies/Autoit-Unittester/UnitTester.au3>
OnAutoItExitRegister("__exit")


_UT_SetNamespace("public api")

;Start server
Global $socket = _Io_Listen(8080, @IPAddress1, Default, $CmdLine[1])

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
	_Io_Emit($socket, "welcome message", "Hello")
EndFunc   ;==>callback_ClientConnected


Func callback_ClientDisconnected(ByRef $socket)

	If _Io_getDeadSocketCount() >= $CmdLine[1] Then AdlibRegister("__exit")

EndFunc   ;==>callback_ClientDisconnected



Func __exit()
	_UT_Set("_Io_getDeadSocketCount", _Io_getDeadSocketCount())
	_Io_Disconnect()
EndFunc
