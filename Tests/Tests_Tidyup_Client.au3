#AutoIt3Wrapper_Change2CUI=Y
#include "..\socketIO.au3"
#include <../Dependencies/Autoit-Unittester/UnitTester.au3>

_UT_SetNamespace("public api")


; Connect to server
Global $socket = _Io_Connect(@IPAddress1, 8080, True)
If  @error Then
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
	;Instantly disconnect
	_Io_Disconnect()
EndFunc   ;==>callback_serverHasGreetedUs

Func callback_WeDisconnectedFromServer($socket)
	Exit
EndFunc   ;==>callback_WeDisconnectedFromServer
