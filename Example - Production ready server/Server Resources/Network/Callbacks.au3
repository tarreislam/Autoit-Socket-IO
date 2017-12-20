#include-once

; ~ Cheat sheet
;
; _Io_Emit($socket, $eventName, $p1-$p16)
; _Io_Broadcast($socket, $eventName, $p1-$p16)
; _Io_BroadcastToAll($socket, $eventName, $p1-$p16)
; _Io_BroadcastToRoom($socket, $roomName, $eventName, $p1-$p16)
;
; _Io_socketGetProperty($socket, $prop)   (Valid props = ip, date). If $prop = default. then an ['ip', 'date']. Sets @error

Func _On_Connection(ByRef $socket)
	#forceref $socket
	Local Const $clientIp = _Io_socketGetProperty($socket, 'ip')

	_Log('+', StringFormat("%s Connected. Requesting login", $clientIp))
	_Io_Emit($socket, 'requestLogin')

EndFunc

Func _On_Disconnect(ByRef $socket)
	#forceref $socket
	Local Const $clientIp = _Io_socketGetProperty($socket, 'ip')

	_Log('!', StringFormat("%s Disconnected.", $clientIp))
EndFunc

Func _On_Flood(ByRef $socket)
	#forceref $socket
	Local Const $clientIp = _Io_socketGetProperty($socket, 'ip')

	_Log('!', StringFormat("%s Flooded.", $clientIp))
EndFunc


Func _On_loginRequest(ByRef $socket, $username, $password)

	If $username == @UserName And $password == "secret!password" Then
		_Log('+', StringFormat('User "%s" auth is ok.', $username))
		_Io_Emit($socket, 'authSucceeded', 'Welcome to heaven')
	Else
		_Log('!', StringFormat('User "%s" auth failed.', $username))
		_Io_Emit($socket, 'authFailed', 'Wrong username or password.')
	EndIf

EndFunc