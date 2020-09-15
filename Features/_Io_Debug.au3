#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_DevDebug
; Description ...: This function will bind important events and report them in both stdOut, stdErr and in files with timestamps and more.
; Syntax ........: _Io_DevDebug()
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: The debugger cannot be disabled after it has been enabled, so be careful to use this in production because the log files will be HUGE.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_DevDebug()
	_Io_DevDebug_Info("# Attaching debugger # ")
	; Log connection events
	; # Server only
	_Event_Listen(_Io_ServerEvents_ListenAttempt, __Io_DevDebug_Listener_Io_ServerEvents_ListenAttempt)
	_Event_Listen(_Io_ServerEvents_FailedToListen, __Io_DevDebug_Listener_Io_ServerEvents_FailedToListen)
	_Event_Listen(_Io_ServerEvents_ListenSucceded, __Io_DevDebug_Listener_Io_ServerEvents_ListenSucceded)

	; # Client only
	_Event_Listen(_Io_ClientEvents_ConnectionAttempt, __Io_DevDebug_Listener_Io_ClientEvents_ConnectionAttempt)
	_Event_Listen(_Io_ClientEvents_FailedToConnect, __Io_DevDebug_Listener_Io_ClientEvents_FailedToConnect)
	_Event_Listen(_Io_ClientEvents_SuccessfullyConnected, __Io_DevDebug_Listener_Io_ClientEvents_SuccessfullyConnected)
	_Event_Listen(_Io_ClientEvents_DisconnectedFromServer, __Io_DevDebug_Listener_Io_ClientEvents_DisconnectedFromServer)

	; # Network traffic
	; Log package events
	_Event_Listen(_Io_CommonEvents_PackageSent, __Io_DevDebug_Listener_Io_CommonEvents_PackageSent)
	_Event_Listen(_Io_CommonEvents_PackageRecvd, __Io_DevDebug_Listener_Io_CommonEvents_PackageRecvd)
	_Event_Listen(_Io_CommonEvents_PrepPackage, __Io_DevDebug_Listener_Io_CommonEvents_PrepPackage)
	; Log event events
	_Event_Listen(_Io_CommonEvents_FireEventAttempt, __Io_DevDebug_Listener_Io_CommonEvents_FireEventAttempt)
	_Event_Listen(_Io_CommonEvents_EventNotFired, __Io_DevDebug_Listener_Io_CommonEvents_EventNotFired)
	_Event_Listen(_Io_CommonEvents_EventFired, __Io_DevDebug_Listener_Io_CommonEvents_EventFired)
	; Misc events
	_Event_Listen(_Io_CommonEvents_Disconnected, __Io_DevDebug_Listener_Io_CommonEvents_Disconnected)
	_Event_Listen(_Io_CommonEvents_Flooded, __Io_DevDebug_Listener_Io_CommonEvents_Flooded)

	_Io_DevDebug_Success("# Debugger attached ")

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_DevDebug_Info
; Description ...:  Write string to regular cw (role.log)
; Syntax ........: _Io_DevDebug_Info($str)
; Parameters ....: $str                 - a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: This does not require _Io_DevDebug() to be initiated
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_DevDebug_Info($str)
	__Io_DevDebug_Writer(">", $str, "INFO")
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_DevDebug_Success
; Description ...:  Write string to regular cw (role.log)
; Syntax ........: _Io_DevDebug_Success($str)
; Parameters ....: $str                 - a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: This does not require _Io_DevDebug() to be initiated
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_DevDebug_Success($str)
	__Io_DevDebug_Writer("+", $str, "SUCCESS")
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_DevDebug_Error
; Description ...: Write string to error cw (role.log)
; Syntax ........: _Io_DevDebug_Error($str)
; Parameters ....: $str                 - a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: This does not require _Io_DevDebug() to be initiated
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_DevDebug_Error($str)
	__Io_DevDebug_Writer("!", $str, "ERROR", True)
EndFunc

#Region Listeners
Func __Io_DevDebug_Listener_Io_CommonEvents_PackageSent(Const $oEvent)

	If $oEvent.item('tcpSentError') <> 0 Then
		_Io_DevDebug_Error(StringFormat("Failed to send package. 0 bytes sent. TcpSend error = %d", $oEvent.item('tcpSentError')))
	Else
		_Io_DevDebug_Success(StringFormat("Package sent. %d bytes sent", $oEvent.item('bytesSent')))
	EndIf
EndFunc

Func __Io_DevDebug_Listener_Io_CommonEvents_PackageRecvd(Const $oEvent)
	_Io_DevDebug_Info(StringFormat('Packaged received. %d bytes recvd', $oEvent.item("bytesRecvd")))
EndFunc

Func __Io_DevDebug_Listener_Io_CommonEvents_FireEventAttempt(Const $oEvent)
	_Io_DevDebug_Info(StringFormat('Attempting to fire event "%s" "$socket = %d", "$mySocket = %d"', $oEvent.item("eventName"), $oEvent.item("socket"), $oEvent.item("mySocket")))
EndFunc

Func __Io_DevDebug_Listener_Io_CommonEvents_EventNotFired(Const $oEvent)
	_Io_DevDebug_Error(StringFormat('Failed fire event "%s" "$socket = %d", "$mySocket = %d". "$reason = %s"', $oEvent.item("eventName"), $oEvent.item("socket"), $oEvent.item("mySocket"), $oEvent.item("reason")))
EndFunc

Func __Io_DevDebug_Listener_Io_CommonEvents_EventFired(Const $oEvent)
	_Io_DevDebug_Success(StringFormat('Successfully fired event "%s" "$socket = %d", "$mySocket = %d"', $oEvent.item("eventName"), $oEvent.item("socket"), $oEvent.item("mySocket")))
EndFunc

Func __Io_DevDebug_Listener_Io_CommonEvents_Disconnected(Const $oEvent)
	_Io_DevDebug_Info(StringFormat('Disconnected "$socket = %d"', $oEvent.item('socket')))
EndFunc

Func __Io_DevDebug_Listener_Io_CommonEvents_Flooded(Const $oEvent)
	_Io_DevDebug_Info(StringFormat('Disconnected "$socket = %d"', $oEvent.item('socket')))
EndFunc

Func __Io_DevDebug_Listener_Io_ServerEvents_FailedToListen(Const $oEvent)
	_Io_DevDebug_Error(StringFormat("Failed to listen on %s:%d. @error = %d. @extended = %d", $oEvent.item('sAddress'), $oEvent.item('iPort'), $oEvent.item('error'), $oEvent.item('extended')))
EndFunc

Func __Io_DevDebug_Listener_Io_ServerEvents_ListenSucceded(Const $oEvent)
	_Io_DevDebug_Success(StringFormat("Successfully listens on %s:%d. $socket = %d", $oEvent.item('sAddress'), $oEvent.item('iPort'), $oEvent.item('socket')))
EndFunc

Func __Io_DevDebug_Listener_Io_ServerEvents_ListenAttempt(Const $oEvent)
	_Io_DevDebug_Info(StringFormat("Attempting to listen on %s:%d", $oEvent.item('sAddress'), $oEvent.item('iPort')))
EndFunc

Func __Io_DevDebug_Listener_Io_ClientEvents_ConnectionAttempt(Const $oEvent)
	_Io_DevDebug_Info(StringFormat("Connecting to %s:%d", $oEvent.item('sAddress'), $oEvent.item('iPort')))
EndFunc

Func __Io_DevDebug_Listener_Io_ClientEvents_FailedToConnect(Const $oEvent)
	_Io_DevDebug_Error(StringFormat("Failed to connect to %s:%d. @error = %d. @extended = %d", $oEvent.item('sAddress'), $oEvent.item('iPort'), $oEvent.item('error'), $oEvent.item('extended')))
EndFunc

Func __Io_DevDebug_Listener_Io_ClientEvents_SuccessfullyConnected(Const $oEvent)
	_Io_DevDebug_Success(StringFormat("Successfully connected to %s:%d. $socket = %d", $oEvent.item('sAddress'), $oEvent.item('iPort'), $oEvent.item('socket')))
EndFunc

Func __Io_DevDebug_Listener_Io_ClientEvents_DisconnectedFromServer(Const $oEvent)
	#forceref $oEvent
	_Io_DevDebug_Error("involuntary disconnect from server")
EndFunc

Func __Io_DevDebug_Listener_Io_CommonEvents_PrepPackage(Const $oEvent)
	_Io_DevDebug_Info(StringFormat('Event "%s" was prepared', $oEvent.item('eventName')))
EndFunc
#EndRegion Listeners

#Region Misc
Func __Io_DevDebug_Writer($prefix, $str, $channel, $bErr = False)
	Local Const $whoAmI = _Io_WhoAmI(True)
	Local Const $now = StringFormat("%s-%s-%s %s:%s:%s", @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)

	$channel = StringFormat("[%s][%s][%s]", $now, $whoAmI, $channel)

	Local Const $logStr = $prefix & $channel & @TAB & $str & @LF

	If Not $bErr Then
		ConsoleWrite($logStr)
	Else
		ConsoleWriteError($logStr)
	EndIf

	Local Const $fileName = $whoAmI & ".log"
	Local Const $lineToWrite = $channel & ": " & $str

	; Write same info to log
	FileWriteLine($fileName, $lineToWrite)
EndFunc

#cs ;Template
Func __Io_DevDebug_Listener(Const $oEvent)
	_Io_DevDebug_Info(StringFormat("", $oEvent.item('')))
EndFunc

#ce
#EndRegion