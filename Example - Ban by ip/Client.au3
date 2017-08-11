#AutoIt3Wrapper_Change2CUI=Y
#include "..\socketIO.au3"

; Connect to server
Global $socket = _Io_Connect(@IPAddress1, 8080)
Global $nReconnectAttempts = 10

If Not @error Then
	ConsoleWrite("Successfully connected to server" & @CRLF)
Else
	ConsoleWrite("Failed to open socket:" & @error & @CRLF)
	Exit
EndIf

; -------------
;	All events are registered here
; -------------

_Io_on("welcome message", callback_serverHasGreetedUs)
_Io_on("disconnect", callback_WeDisconnectedFromServer)
_Io_on("banned", callback_BannedFromServer)

; Start main loop
While _Io_Loop($socket)
WEnd

; -------------
;	All event callbacks are defined here
; -------------

Func callback_serverHasGreetedUs(ByRef $socket, $message)
	MsgBox(0, "The Client", "Message received from server: " & $message & @CRLF & "Press OK to send something back to the server")
	_Io_Emit($socket, "message from client", "Hello from client!")
EndFunc   ;==>callback_serverHasGreetedUs

Func callback_WeDisconnectedFromServer(ByRef $socket)
	ConsoleWrite("Lost connection to server " & @LF)
	MsgBox(0, "The Client", "Lost connection to server... Trying to reconnect....  #" & $nReconnectAttempts)
	$nReconnectAttempts-=1

	If $nReconnectAttempts == 0 Then Exit

EndFunc   ;==>callback_WeDisconnectedFromServer



Func callback_BannedFromServer(ByRef $socket, $created_at, $expires_at, $sReason, $sIssuedBy)
	Local $nBanDuration = round(($expires_at - $created_at) / 60)
	Local $nTimeLeft = round(($expires_at - createTimestamp() )/ 60)
	MsgBox(0, "Whops!", "You got banned for " & $nBanDuration & " minutes." & @LF & @LF & "Reason: " & $sReason & @LF & "Banned by: " & $sIssuedBy & @LF & "Ban expires in: " & $nTimeLeft & " minutes")
	TCPCloseSocket($socket)
EndFunc


Func createTimestamp(); yyyy-mm-dd hh:ii in seconds
	Return (@YEAR * 31556952) + (@MON * 2629746) + (@MDAY * 86400) + (@HOUR * 3600) + (@MIN * 60) + @SEC
EndFunc