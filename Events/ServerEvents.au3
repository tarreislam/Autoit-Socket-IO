#include-once

#Region Events
; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_ServerEvents_ListenAttempt
; Description ...:  This event is fired when _Io_listen is executed
; Syntax ........: _Io_ServerEvents_ListenAttempt(Const Byref $oEvent)
; Parameters ....: $oEvent              - [in/out and const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ServerEvents_ListenAttempt(Const ByRef $oEvent, Const $iPort, Const $sAddress)
	$oEvent.add("iPort", $iPort)
	$oEvent.add("sAddress", $sAddress)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_ServerEvents_FailedToListen
; Description ...: This event is fired if The server failed to listen (TcipListen). error and extended is set
; Syntax ........: _Io_ServerEvents_FailedToListen(Const Byref $oEvent, $error, $extended)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $error               - an unknown value.
;                  $extended            - an unknown value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ServerEvents_FailedToListen(Const ByRef $oEvent, $error, $extended, Const $iPort, Const $sAddress)
	$oEvent.add("error", $error)
	$oEvent.add("extended", $extended)
	$oEvent.add("iPort", $iPort)
	$oEvent.add("sAddress", $sAddress)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_ServerEvents_ListenSucceded
; Description ...: This event is fired when a server successfully listens on a given ip:port
; Syntax ........: _Io_ServerEvents_ListenSucceded(Const Byref $oEvent)
; Parameters ....: $oEvent              - [in/out and const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ServerEvents_ListenSucceded(Const ByRef $oEvent, Const $socket, Const $iPort, Const $sAddress)
	$oEvent.add("socket", $socket)
	$oEvent.add("iPort", $iPort)
	$oEvent.add("sAddress", $sAddress)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_ServerEvents_ClientConnected
; Description ...:  This event is fired when a client connects toa server (TcpAccept)
; Syntax ........: _Io_ServerEvents_ClientConnected(Const Byref $oEvent, $connctedSocket, $mySocket)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $connctedSocket      - an unknown value.
;                  $mySocket            - a map.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ServerEvents_ClientConnected(Const ByRef $oEvent, $connctedSocket, $mySocket)
	$oEvent.add("connectedSocket", $connctedSocket)
	$oEvent.add("mySocket", $mySocket)
EndFunc   ;==>_Io_ServerEvents_ClientConnected

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_ServerEvents_ClientDisconnected
; Description ...:  This event is fired when a previously connected client disconnects from the server
; Syntax ........: _Io_ServerEvents_ClientDisconnected(Const Byref $oEvent, $connctedSocket, $mySocket)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $connctedSocket      - an unknown value.
;                  $mySocket            - a map.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ServerEvents_ClientDisconnected(Const ByRef $oEvent, $connctedSocket, $mySocket)
	$oEvent.add("connectedSocket", $connctedSocket)
	$oEvent.add("mySocket", $mySocket)
EndFunc   ;==>_Io_ServerEvents_ClientDisconnected
#EndRegion Events

#Region Listeners
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: _Io_ServerEvents_ClientConnected_RegisterSocket
; Description ...: For each new connected socket, we add them to our list of sockets for later use
; Syntax ........: _Io_ServerEvents_ClientConnected_RegisterSocket(Const $oEvent)
; Parameters ....: $oEvent              - [const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ServerEvents_ClientConnected_RegisterSocket(Const $oEvent)
	#forcedef $g__io_Sockets
	Local Const $connectedSocket = $oEvent.item("connectedSocket")

	; Get some info about the socket
	Local Const $connectedAt = StringFormat("%s-%s-%s %s:%s:%s", @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)
	Local Const $ipAddress = __Io_SocketToIP($connectedSocket)

	Local Const $oSocket = ObjCreate("Scripting.Dictionary")

	$oSocket.add("connected_at", $connectedAt)
	$oSocket.add("ip", $ipAddress)

	; Add socket to global register
	$g__io_Sockets.add($connectedSocket, $oSocket)
EndFunc   ;==>_Io_ServerEvents_ClientConnected_RegisterSocket

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: _Io_ServerEvents_ClientConnected_FireInternalEvent_Connected
; Description ...: Fires an event to _Io_ON("connection", ...)
; Syntax ........: _Io_ServerEvents_ClientConnected_FireInternalEvent_Connected(Const $oEvent)
; Parameters ....: $oEvent              - [const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ServerEvents_ClientConnected_FireInternalEvent_Connected(Const $oEvent)
	; Fire the regular event that something connected

	Local Const $connectedSocket = $oEvent.item("connectedSocket")
	Local Const $mySocket = $oEvent.item("mySocket")

	_Io_FireIoEvent("connection", Null, $connectedSocket, $mySocket)
EndFunc   ;==>_Io_ServerEvents_ClientConnected_FireInternalEvent_Connected

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: _Io_ServerEvents_ClientDisconnected_UnRegisterSocket
; Description ...: If the client disconnects, we remove it from our list of sockets to prevent error and potential memory leaks
; Syntax ........: _Io_ServerEvents_ClientDisconnected_UnRegisterSocket(Const $oEvent)
; Parameters ....: $oEvent              - [const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ServerEvents_ClientDisconnected_UnRegisterSocket(Const $oEvent)
	#forcedef $g__io_Sockets
	Local Const $socket = $oEvent.item("connectedSocket")
	; Remove
	$g__io_Sockets.remove($socket)
EndFunc   ;==>_Io_ServerEvents_ClientDisconnected_UnRegisterSocket

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: _Io_ServerEvents_ClientDisconnected_NativeEvent_Disconnect
; Description ...: Fires an event to _Io_ON("disconnect", ...)
; Syntax ........: _Io_ServerEvents_ClientDisconnected_NativeEvent_Disconnect(Const Byref $oEvent)
; Parameters ....: $oEvent              - [in/out and const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ServerEvents_ClientDisconnected_FireInternalEvent_Disconnect(Const ByRef $oEvent)
	Local Const $connctedSocket = $oEvent.item("connectedSocket")
	Local Const $mySocket = $oEvent.item("mySocket")

	_Io_FireIoEvent("disconnect", Null, $connctedSocket, $mySocket)
EndFunc   ;==>_Io_ServerEvents_ClientDisconnected_FireInternalEvent_Disconnect
#EndRegion Listeners

#Region Internals
Func __Io_SocketToIP(Const $socket) ;ty javiwhite
	Local Const $hDLL = "Ws2_32.dll"
	Local $structName = DllStructCreate("short;ushort;uint;char[8]")
	Local $sRet = DllCall($hDLL, "int", "getpeername", "int", $socket, "ptr", DllStructGetPtr($structName), "int*", DllStructGetSize($structName))
	If Not @error Then
		$sRet = DllCall($hDLL, "str", "inet_ntoa", "int", DllStructGetData($structName, 3))
		If Not @error Then Return $sRet[0]
	EndIf
	Return StringFormat("~%s.%s.%s.%s", Random(1, 255, 1), Random(1, 255, 1), Random(0, 10, 1), Random(1, 255, 1)) ;We assume this is a fake socket and just generate a random IP
EndFunc   ;==>__Io_SocketToIP
#EndRegion Internals
