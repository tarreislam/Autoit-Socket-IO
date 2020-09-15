#include-once

#Region Events
; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_CommonEvents_IoRoleDecided
; Description ...: This event is fired whenever_Io_Listen or _Io_Connect is called
; Syntax ........: _Io_CommonEvents_IoRoleDecided(Const Byref $oEvent)
; Parameters ....: $oEvent              - [in/out and const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_IoRoleDecided(Const ByRef $oEvent, $oldRole, $newRole)
	$oEvent.add("oldRole", $oldRole)
	$oEvent.add("newRole", $newRole)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_CommonEvents_Initiated
; Description ...: This event is fired if _Io_Connect or _Io_listen succeded
; Syntax ........: _Io_CommonEvents_Initiated(Const Byref $oEvent)
; Parameters ....: $oEvent              - [in/out and const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: There are also individual events for server and clients
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_Initiated(Const ByRef $oEvent, Const $socket)
	$oEvent.add("socket", $socket)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_CommonEvents_Disconnected
; Description ...: This event is fired if _Io_Disconnect() is called without a given parameter
; Syntax ........: _Io_CommonEvents_Disconnected(Const Byref $oEvent, $socket)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $socket              - a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_Disconnected(Const ByRef $oEvent, $socket)
	$oEvent.add("socket", $socket)
EndFunc   ;==>_Io_CommonEvents_Disconnected

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_CommonEvents_Flooded
; Description ...: This event is fired if the recvd package reaches $g__io_nMaxPacketSize (set by _Io_setMaxRecvPackageSize)
; Syntax ........: _Io_CommonEvents_Flooded(Const Byref $oEvent, $connctedSocket)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $connctedSocket      - an unknown value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_Flooded(Const ByRef $oEvent, $connctedSocket)
	$oEvent.add("socket", $connctedSocket)
EndFunc   ;==>_Io_CommonEvents_Flooded

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_CommonEvents_FireEventAttempt
; Description ...: This event is fired when an attempt of _Io_FireIoEvent is made
; Syntax ........: _Io_CommonEvents_FireEventAttempt(Const Byref $oEvent, Const Byref $eventName, Const Byref $eventData, Const Byref $socket,
;                  Const Byref $mySocket)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $eventName           - [in/out and const] an unknown value.
;                  $eventData           - [in/out and const] an unknown value.
;                  $socket              - [in/out and const] a string value.
;                  $mySocket            - [in/out and const] a map.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_FireEventAttempt(Const ByRef $oEvent, Const ByRef $eventName, Const ByRef $eventData, Const ByRef $socket, Const ByRef $mySocket)
	$oEvent.add("eventName", $eventName)
	$oEvent.add("eventData", $eventData)
	$oEvent.add("socket", $socket)
	$oEvent.add("mySocket", $mySocket)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_CommonEvents_EventFired
; Description ...: This event is fired if the the function callback of _Io_On callable was ran successfully
; Syntax ........: _Io_CommonEvents_EventFired(Const Byref $oEvent, Const $eventCallable, Const $eventData)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $eventCallable       - [const] an unknown value.
;                  $eventData           - [const] an unknown value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_EventFired(Const ByRef $oEvent, Const ByRef $eventName, Const ByRef $eventData, Const ByRef $socket, Const ByRef $mySocket)
	$oEvent.add("eventName", $eventName)
	$oEvent.add("eventData", $eventData)
	$oEvent.add("socket", $socket)
	$oEvent.add("mySocket", $mySocket)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_CommonEvents_EventNotFired
; Description ...: This event is fired if something caused the event not to be fired
; Syntax ........: _Io_CommonEvents_EventNotFired(Const Byref $oEvent, Const $eventCallable, Const $eventData)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $eventCallable       - [const] an unknown value.
;                  $eventData           - [const] an unknown value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: `$reason` can either be `NOT_FOUND` or `0xDEAD_0xBEEF`
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_EventNotFired(Const ByRef $oEvent, Const ByRef $eventName, Const ByRef $eventData, Const ByRef $socket, Const ByRef $mySocket, Const $reason)
	$oEvent.add("eventName", $eventName)
	$oEvent.add("eventData", $eventData)
	$oEvent.add("socket", $socket)
	$oEvent.add("mySocket", $mySocket)
	$oEvent.add("reason", $reason)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_CommonEvents_PackageSent
; Description ...: This event is fired after after each call of _Io_SendPackage
; Syntax ........: _Io_CommonEvents_PackageSent(Const Byref $oEvent, Const $bytesSent, Const $tcpSentError)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $bytesSent           - [const] a boolean value.
;                  $tcpSentError        - [const] a dll struct value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_PackageSent(Const ByRef $oEvent, Const $socket, Const $bytesSent, Const $tcpSentError)
	$oEvent.add("socket", $socket)
	$oEvent.add("bytesSent", $bytesSent)
	$oEvent.add("tcpSentError", $tcpSentError)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_CommonEvents_PrepPackage
; Description ...: This event is fired when _Io_PrepPackage is called
; Syntax ........: _Io_CommonEvents_PrepPackage(Const Byref $oEvent, Const $eventName)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $eventName           - [const] an unknown value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_PrepPackage(Const ByRef $oEvent, Const $eventName)
	$oEvent.add("eventName", $eventName)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_CommonEvents_PackageRecvd
; Description ...: This is event is fired when some kind of data was received via TcpRecv (_Io_Loop)
; Syntax ........: _Io_CommonEvents_PackageRecvd(Const Byref $oEvent, Const $bytesRecvd)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $bytesRecvd          - [const] a boolean value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: The event is fired in an internal function called __Io_RecvPackage
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_PackageRecvd(Const ByRef $oEvent, Const $bytesRecvd)
	$oEvent.add("bytesRecvd", $bytesRecvd)
EndFunc
#EndRegion Events

#Region Listeners
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: _Io_CommonEvents_Disconnected_UnRegisterEvents
; Description ...: This will remove all events registred from the given socket (IE, stuff added with _Io_On('xxxx', ....), not internals tho, since they are hardFired
; Syntax ........: _Io_CommonEvents_Disconnected_UnRegisterEvents(Const $oEvent)
; Parameters ....: $oEvent              - [const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_Disconnected_UnRegisterEvents(Const $oEvent)
	#forceref $oEvent
	#forcedef $g__io_Events

	$g__io_Events.remove($oEvent.item("socket"))
EndFunc   ;==>_Io_CommonEvents_Disconnected_UnRegisterEvents

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: _Io_CommonEvents_Disconnected_ShutDownTcpService
; Description ...: This will make the _Io_Loop quit, and TcpShutdown will be ran. Effectivly killing the
; Syntax ........: _Io_CommonEvents_Disconnected_ShutDownTcpService(Const $oEvent)
; Parameters ....: $oEvent              - [const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_Disconnected_ShutDownTcpService(Const $oEvent)
	#forcedef $g__io_isActive
	#forceref $oEvent, $g__io_isActive
	; Set loop status to false
	$g__io_isActive = False
	; Shut down TCP services
	TCPShutdown()
EndFunc   ;==>_Io_CommonEvents_Disconnected_ShutDownTcpService


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: _Io_CommonEvents_DisconnectSocket
; Description ...:  This will run _Io_Disconnect on a given socket, on server, it will disconnect the client, on client, it will disconnect from server
; Syntax ........: _Io_CommonEvents_DisconnectSocket(Const $oEvent)
; Parameters ....: $oEvent              - [const] an object.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_CommonEvents_DisconnectSocket(Const $oEvent)
	Local Const $socket = $oEvent.item("socket")
	_Io_Disconnect($socket)
EndFunc   ;==>_Io_CommonEvents_DisconnectSocket
; Internalz
#EndRegion Listeners
