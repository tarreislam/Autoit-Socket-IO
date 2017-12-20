#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7
#include "..\socketIO.au3"

Global $socket = _Io_Connect(@IPAddress1, 1337)
If @error then Exit

_Io_On('requestLogin')
_Io_On('authSucceeded')
_Io_On('authFailed')


While _Io_loop($socket)

WEnd

Func _On_requestLogin(ByRef $socket)
	_Io_Emit($socket, 'loginRequest', @UserName, "secret!password")
EndFunc

Func _On_authSucceeded(ByRef $socket, $message)
	#forceref $socket
	MsgBox(64, 'Success!', $message)
EndFunc

Func _On_authFailed(ByRef $socket, $message)
	#forceref $socket
	MsgBox(16, 'Failure!', $message)
EndFunc