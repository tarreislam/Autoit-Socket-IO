
; SocketIO will bind these events accordingly.
_Io_On('connection'); _On_connection
_Io_On('disconnect'); _On_disconnect
_Io_On('newFancyNumber'); _On_newFancyNumber

Func _On_connection(Const $socket)
	ConsoleWrite("Someone connected" & @LF)
	; Display the current value of our fancy number
	ConsoleWrite("$myFancyNumber = " & $myFancyNumber & @LF)

	; A client has connected. Ask them to multiply this variable by a factor of two
	_Io_Emit($socket, 'multiply', $myFancyNumber, 2)
EndFunc

Func _On_disconnect(Const $socket)
	ConsoleWrite("Someone disconnected" & @LF)
EndFunc

Func _On_newFancyNumber(Const $socket, $newFancyNumber)
	; The client has sent back our fancy number. Replace it
	$myFancyNumber = $newFancyNumber
	; Ta-da
	ConsoleWrite("$myFancyNumber = " & $myFancyNumber & @LF)
EndFunc