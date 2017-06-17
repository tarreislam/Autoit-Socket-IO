#AutoIt3Wrapper_Change2CUI=Y

#include "..\socketIO.au3"

Global $users[1]

If Not @Compiled Then
	MsgBox(0, "", "You should compile me")
	;Exit
EndIf

Local $server = _Io_Listen(1337)
If @error Then
	MsgBox(0, "Failed to listen on 1337", @error)
	Exit
EndIf

ConsoleWrite("Listening on port 1337" & @CRLF)
   
; Define our events
_Io_on("connection", ClientConnected)
_Io_on("message", Message)
_Io_on("disconnect", Disconnected)
_Io_on("join", ClientJoined)
_Io_on("request", parseRequest)


; Main loop of our script
While _Io_Loop($server)
WEnd


Func ClientConnected(ByRef $socket)
	ConsoleWrite("Client connected, sending welcome message" & @CRLF)
	_Io_Emit($socket, "message", "Server", "Hello and welcome!")
EndFunc

Func Disconnected(ByRef $socket)
	Local $extendedInfo = _Io_socketGetProperty($socket)
	ConsoleWrite("Client disconnected " & @CRLF & "IP: " & $extendedInfo[1] & @CRLF & "Date entered: " & $extendedInfo[2] & @CRLF & @CRLF)

	; Remove users from our array
	Local $removedUserName = removeUserBySocket($socket)

	; Send new userlist to all clients
	_Io_BroadcastToAll($socket, "userlist", getUserListAsStringArray())

	; Notify all clients our great loss

	_Io_BroadcastToAll($socket, "message", "Server", $removedUserName & " has left the chat.")

EndFunc

Func Message(ByRef $socket, $name, $message)
	; Transit message the message
	_Io_BroadcastToAll($socket, "message", $name, $message)
	ConsoleWrite($name & ": " & $message & @CRLF)
EndFunc

Func ClientJoined(ByRef $socket, $name)
	ConsoleWrite("Client joined: " & $name & @CR)
	; Save the username in the server
	Local $userData = [$socket, $name]
	__io_Push($users, $userData)

	; Tell everyone that we have a new joiner (Beseides the joiner)
	_Io_Broadcast($socket, "joined", $name)
EndFunc

Func parseRequest(ByRef $socket, $request)
	ConsoleWrite("Client requested: " & $request & @CRLF)

	Switch $request
		Case "userlist"
			_Io_Emit($socket, "userlist", getUserListAsStringArray())
	EndSwitch
EndFunc



Func getUserListAsStringArray()
	Local $user_names = ""

	For $i = 1 to $users[0]
		Local $userData = $users[$i]
		$user_names &= $userData[1] & "|"
	Next

	Return $user_names
EndFunc

Func removeUserBySocket($socket)
	Local $tmp = $users, $deletedUserName = Null

	Global $users[1] = [0]

	For $i = 1 to $tmp[0]
		Local $tmpData = $tmp[$i]
		If $tmpData[0] == $socket Then
			$deletedUserName = $tmpData[1]
			ContinueLoop
		EndIf
		__io_Push($users, $tmpData)
	Next

	Return $deletedUserName
EndFunc



