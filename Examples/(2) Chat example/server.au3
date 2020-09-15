; Make this an console application
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Run_After=start cmd /c server.exe
; Include IO core + the features we want to use for the server
#include "..\..\socketIO-Core.au3"
#include "..\..\Features\_Io_Emit.au3"
#include "..\..\Features\_Io_Broadcast.au3"
#include "..\..\Features\_Io_Debug.au3"

; Define some resources
Global $userList = ObjCreate("Scripting.Dictionary")

; Attempt to listen on port 1000
Global $socket = _Io_listen(1000)

If Not $socket Then
	MsgBox(64, "Failed to start server", "Failed to listen on port 1000. Is it already listening?")
	Exit
EndIf

_Io_DevDebug() ; Uncomment to attach deubber

; Register Io events
_Io_On('connection')
_Io_On('disconnect')
_Io_On('auth')
_Io_On('message')


; Main loop
While _Io_Loop($socket)
WEnd


#Region Io events

Func _On_connection(Const $socket)
	; We want the user to identify themselfs
	_Io_Emit($socket, 'authRequest')
EndFunc   ;==>_On_connection

Func _On_auth(Const $socket, $name, $password)

	; retrieve password from the given user

	Local $userPwd = IniRead("database.ini", "users", $name, "")
	; Check if the passwords match
	If $userPwd == $password And $password <> "" Then
		; Add users to our "userList"
		Local $oUser = ObjCreate("scripting.dictionary")

		$oUser.add("name", $name)
		$oUser.add("joined_at", StringFormat("%s/%s %d:%s", @MDAY, @MON, @HOUR, @MIN))

		$userList.add($socket, $oUser)

		; tell the user the auth was successful
		_Io_Emit($socket, 'authSuccessful')
		; Send updated userlist to everyone
		_Io_BroadcastToAll($socket, 'userListUpdate', $userList)
		; Send welcome message to everyone
		_Io_BroadcastToAll($socket, "message", StringFormat("%s just joined the chat!", $name))
		; Send welcome message to user
		_Io_Emit($socket, "message", StringFormat("Welcome to the chat %s, type /help to see a list of commands", $name))

	Else
		; tell the user the auth was unsuccessful (IE bad password)
		_Io_Emit($socket, 'authUnSuccessful')
	EndIf

EndFunc   ;==>_On_auth

Func _On_disconnect(Const $socket)

	; Update the list only if the disconnected socket did not exist
	If $userList.exists($socket) Then
		$userList.remove($socket)
		_Io_BroadcastToAll($socket, 'userListUpdate', $userList)
	EndIf

EndFunc   ;==>_On_disconnect

Func _On_Message(Const $socket, $message)
	; Get current timestamp (YYYY-MM-DD HH:MM:SS)
	Local Const $now = StringFormat("%s-%s-%s %s:%s:%s", @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)
	; Fetch user by socket
	Local Const $oUser = $userList.item($socket)
	; To prevent everyne to see what / commands they are using, we flag the usage so we do not broadcast that info!
	Local $bSlashCommandUsed = StringLeft($message, 1) == "/"

	; Prepend timestamp, username and password to new message
	Local Const $newMessage = StringFormat("[%s] %s: %s", $now, $oUser.item("name"), $message)

	If Not $bSlashCommandUsed Then
		;Broadcast message to everyone
		_Io_BroadcastToAll($socket, "message", $newMessage)
	Else
		;Broadcast message to initator
		_Io_Emit($socket, "message", $newMessage)
	EndIf

	; If a message starts with a slash, its a special message
	If $bSlashCommandUsed Then

		Local Const $command = StringMid($message, 2)

		; Emotes
		If $command == "dance" Then
			; Broadcast dance emote to everyone
			Return _Io_BroadcastToAll($socket, "message", StringFormat("%s bursts into dance!", $oUser.item("name")))

		ElseIf $command == "help" Then

			_Io_Emit($socket, "message", "/help (See all commands)" & @CRLF & "/dance (dance for the chat)" & @CRLF & "/joinedAt (See when you joined the chat)" & @CRLF & "/changePassword [newPassword] (Change your current password)" & @CRLF & "/new-user [username] [password] (Creates a new user)")

		ElseIf $command == "joinedAt" Then

			; Emit private info
			_Io_Emit($socket, "message", "[Only you will see this message]: %s" & $oUser.item("joined_at"))

		ElseIf StringRegExp($command, "(?i)^changePassword") Then

			; Passwor change request
			Local $sNewPassword = StringRegExp($message, "(?i)changePassword\h*(.+)", 1)

			If Not @error Then
				$sNewPassword = $sNewPassword[0]
				; Write new password to database
				IniWrite("database.ini", "users", $oUser.item("name"), $sNewPassword)
				; Emit private message that the password was successfully created
				_Io_Emit($socket, "message", "Password successfully changed!")
			Else
				; Invalid password
				_Io_Emit($socket, "message", "Invalid password")
			EndIf

		ElseIf StringRegExp($command, "(?i)new-user\h*(.*)\h+(.*)") Then

			; NEw user request
			Local $aNewUser = StringRegExp($message, "(?i)new-user\h*(.*)\h+(.*)", 1)

			If Not @error Then
				Local $userName = $aNewUser[0]
				Local $password = $aNewUser[1]


				; Check that the user does not exists
				If IniRead("database.ini", "users", $userName, "") == "" Then
					; Write to database
					IniWrite("database.ini", "users", $userName, $password)
					_Io_Emit($socket, "message", StringFormat("The user %s was successfully created", $userName))
				Else
					_Io_Emit($socket, "message", StringFormat("The username %s is already taken. please select another one", $userName))
				EndIf
			Else
				; Invalid user creation
				_Io_Emit($socket, "message", "Invalid syntax. /new-user username password")
			EndIf

		Else

			; No command found
			_Io_Emit($socket, "message", "Invalid command " & $message)
		EndIf

	EndIf

EndFunc   ;==>_On_Message

#EndRegion Io events

