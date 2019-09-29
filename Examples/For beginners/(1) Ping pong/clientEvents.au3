
; SocketIO will bind these events accordingly.
_Io_On('ping'); _On_ping

Func _On_Ping(Const $socket)
	ConsoleWrite("CLIENT: PING" & @LF)
	Sleep(1000); ONly for demonstration.
	_Io_Emit($socket, 'ping')
EndFunc