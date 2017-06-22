#AutoIt3Wrapper_Change2CUI=Y
#include "..\socketIO.au3"
#include <../Packages/Autoit-Unittester/UnitTester.au3>

_UT_SetNamespace("public api")

_UT_Set("@client client connected to server", False)
_UT_Set("@client client disconnected from server", False)
_UT_Set("@client client recvd message from server", False)

; Connect to server
Global $socket = _Io_Connect(@IPAddress1, 8080, True)
If  @error Then
	_UT_Set("@client client connected to server", False)
	Exit
Else
	_UT_Set("@client client connected to server", True)
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
	_UT_Set("@client client recvd message from server", True)
	_UT_Set("@welcome message", $message)
	_Io_Emit($socket, "message from client", "Hello from client!")
EndFunc   ;==>callback_serverHasGreetedUs

Func callback_WeDisconnectedFromServer($socket)
	_UT_Set("@client client disconnected from server", True)
	Exit
EndFunc   ;==>callback_WeDisconnectedFromServer
