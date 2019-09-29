
; SocketIO will bind these events accordingly.
_Io_On('multiply'); _On_multiply

Func _On_multiply(Const $socket, $fancyNumber, $multiplier)
	ConsoleWrite("CLIENT: Server asked us to multiply $fancyNumber by $multiplier and send it back" & @LF)

	Local $newFancyNumber = $fancyNumber * $multiplier

	ConsoleWrite("CLIENT: The new fancy number is " & $newFancyNumber & @LF)

	_Io_Emit($socket, 'newFancyNumber', $newFancyNumber)
EndFunc