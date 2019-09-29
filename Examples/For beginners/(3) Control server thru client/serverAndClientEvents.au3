
; SocketIO will bind these events accordingly.
_Io_On('connection'); _On_connection
_Io_On('disconnect'); _On_disconnect
_Io_On('changeInput'); _On_newFancyNumber


; This event is only fired on the server
Func _On_connection(Const $socket)
	#forcedef $inputName, $inputAddress
	ConsoleWrite("Someone connected" & @LF)

	; Since a new client joined. We have to send him the data all the other nodes have
	_Io_Emit($socket, 'changeInput', GUICtrlRead($inputName), GUICtrlRead($inputAddress))

EndFunc

; This event is fired on both the server and the client
Func _On_disconnect(Const $socket)
	#forcedef $hGUI

	If _Io_IsServer() Then
		ConsoleWrite("Someone disconnected" & @LF)
	EndIf

	If _Io_IsClient() Then
		MsgBox(64, "", "Not connected to server. Exiting", 0, $hGUI)
		Exit
	EndIf
EndFunc

; This event is fired on both the server and the client
Func _On_changeInput(Const $socket, $name, $address)
	#forcedef $inputName, $inputAddress
	GUICtrlSetData($inputName, $name)
	GUICtrlSetData($inputAddress, $address)

	; Since we are sharing events with client and server. We can make an easy check to run server-only events
	If _Io_IsServer() Then
		_Io_Broadcast($socket, 'changeInput', $name, $address)
	EndIf
EndFunc