
; SocketIO will bind these events accordingly.
_Io_On('connection'); _On_connection
_Io_On('disconnect'); _On_disconnect
_Io_On('ping'); _On_ping

Func _On_connection(Const $socket)
	ConsoleWrite("Someone connected" & @LF)

	; Here we will send the event "ping" to our client.
	_Io_Emit($socket, 'ping')
EndFunc

Func _On_disconnect(Const $socket)
	ConsoleWrite("Someone disconnected" & @LF)
EndFunc

Func _On_ping(Const $socket)
	; Client sent us an PONG
	ConsoleWrite("SERVER: PONG" & @LF)
	Sleep(1000); ONly for demonstration.
	; We respond with a ping
	_Io_Emit($socket, 'ping')
EndFunc