#include-once

#Region Events

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_ClientEvents_ConnectionAttempt
; Description ...: This event is fired when a connection attempt was made to a given server
; Syntax ........: _Io_ClientEvents_ConnectionAttempt(Const Byref $oEvent, Const $sAddress, Const $iPort)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $sAddress            - [const] a string value.
;                  $iPort               - [const] an integer value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ClientEvents_ConnectionAttempt(Const ByRef $oEvent, Const $sAddress, Const $iPort)
	$oEvent.add("iPort", $iPort)
	$oEvent.add("sAddress", $sAddress)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_ClientEvents_FailedToConnect
; Description ...: This event is fired when TcpConnect failed
; Syntax ........: _Io_ClientEvents_FailedToConnect(Const Byref $oEvent, $error, $extended)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $error               - an unknown value.
;                  $extended            - an unknown value.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ClientEvents_FailedToConnect(Const ByRef $oEvent, $error, $extended, Const $sAddress, Const $iPort)
	$oEvent.add("error", $error)
	$oEvent.add("extended", $extended)
	$oEvent.add("iPort", $iPort)
	$oEvent.add("sAddress", $sAddress)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_ClientEvents_SuccessfullyConnected
; Description ...:  This event is fired when a connection attempt was successfull
; Syntax ........: _Io_ClientEvents_SuccessfullyConnected(Const Byref $oEvent)
; Parameters ....: $oEvent              - [in/out and const] an object.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ClientEvents_SuccessfullyConnected(Const ByRef $oEvent, Const $socket, Const $sAddress, Const $iPort)
	$oEvent.add("socket", $socket)
	$oEvent.add("iPort", $iPort)
	$oEvent.add("sAddress", $sAddress)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_ClientEvents_DisconnectedFromServer
; Description ...: This event is fired if the server disconnected us.
; Syntax ........: _Io_ClientEvents_DisconnectedFromServer(Const Byref $oEvent, Const $lastUsedIp, Const $lastUsedPort)
; Parameters ....: $oEvent              - [in/out and const] an object.
;                  $lastUsedIp          - [const] an unknown value.
;                  $lastUsedPort        - [const] an unknown value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ClientEvents_DisconnectedFromServer(Const ByRef $oEvent, Const $socket, Const $lastUsedIp, Const $lastUsedPort)
	$oEvent.add("socket", $socket)
	$oEvent.add("lastUsedIp", $lastUsedIp)
	$oEvent.add("lastUsedPort", $lastUsedPort)
EndFunc   ;==>__Io_ClientEvents_DisconnectedFromServer
#EndRegion Events

#Region Listeners

#EndRegion Listeners
