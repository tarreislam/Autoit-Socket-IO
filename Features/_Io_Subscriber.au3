#include-once
Global Const $g__io_SubscriberRooms = ObjCreate("Scripting.Dictionary")

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_getSubscriberRooms
; Description ...: Get a list of all subscriber rooms.
; Syntax ........: _Io_getSubscriberRooms()
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_getSubscriberRooms()
	return $g__io_SubscriberRooms
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Subscribe
; Description ...: Server-side only. Subscribes a socket to a room.
; Syntax ........: _Io_Subscribe(Const $socket, $sRoomName)
; Parameters ....: $socket              - [in/out] a string value.
;                  $sRoomName           - a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......: _Io_BroadcastToRoom, _Io_Unsubscribe
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Subscribe(Const $socket, $sRoomName)
	Local $oRoom

	; Create room if it does not eixst
	If Not $g__io_SubscriberRooms.exists($sRoomName) Then
		$oRoom = ObjCreate("Scripting.Dictionary")
		$g__io_SubscriberRooms.add($sRoomName, $oRoom)
	Else
		$oRoom = $g__io_SubscriberRooms.item($sRoomName)
	EndIf

	; Add socket to room
	$oRoom.add($socket, $socket)
EndFunc   ;==>_Io_Subscribe

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Unsubscribe
; Description ...: Server-side only. Unsubscribes a socket from a room.
; Syntax ........: _Io_Unsubscribe(Const $socket, $sRoomName)
; Parameters ....: $socket              - [in/out] a string value.
;                  $sRoomName           - a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......: _Io_Subscribe, _Io_UnsubscribeFromAll
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Unsubscribe(Const $socket, $sRoomName)

	If Not $g__io_SubscriberRooms.exists($sRoomName) Then Return SetError(1, 0, Null)
	Local Const $oRoom = $g__io_SubscriberRooms.exists($sRoomName)

	; Remove socket from room
	If $oRoom.exists($socket) Then $oRoom.remove($socket)

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_UnsubscribeFromAll
; Description ...:  Server-side only. Unsubscribes a socket from all rooms.
; Syntax ........: _Io_UnsubscribeFromAll(Const $socket)
; Parameters ....: $socket              - [const] a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......: _Io_Subscribe, _Io_Unsubscribe
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_UnsubscribeFromAll(Const $socket)

	For $room in $g__io_SubscriberRooms.keys()
		_Io_Unsubscribe($socket, $room)
	Next

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_BroadcastToRoom
; Description ...: Server-side only. Emit an event to every socket subscribed to a given room
; Syntax ........: _Io_BroadcastToRoom(Const $socket, $sDesiredRoomName, $sEventName[, $p1 = Default[, $p2 = Default[, $p3 = Default[,
;                  $p4 = Default[, $p5 = Default[, $p6 = Default[, $p7 = Default[, $p8 = Default[, $p9 = Default[,
;                  $p10 = Default[, $p11 = Default[, $p12 = Default[, $p13 = Default[, $p14 = Default[, $p15 = Default[,
;                  $p16 = Default]]]]]]]]]]]]]]]])
; Parameters ....: $socket              - [in/out] a string value.
;                  $sDesiredRoomName    - a string value.
;                  $sEventName          - a string value.
;                  $p1                  - [optional] a pointer value. Default is Default.
;                  $p16                 - [optional] a pointer value. Default is Default.
; Return values .: Integer. Bytes sent
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: To pass more than 16 parameters, a special array can be passed in lieu of individual parameters. This array must have its first element set to "CallArgArray" and elements 1 - n will be passed as separate arguments to the function. If using this special array, no other arguments can be passed
; Related .......: _Io_Emit, _Io_Broadcast, _Io_BroadcastToAll, _Io_Subscribe
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_BroadcastToRoom(Const $socket, $sDesiredRoomName, $sEventName, $p1 = Default, $p2 = Default, $p3 = Default, $p4 = Default, $p5 = Default, $p6 = Default, $p7 = Default, $p8 = Default, $p9 = Default, $p10 = Default, $p11 = Default, $p12 = Default, $p13 = Default, $p14 = Default, $p15 = Default, $p16 = Default)
	#forceref $socket
	; What to send
	Local $aParams = [$p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10, $p11, $p12, $p13, $p14, $p15, $p16]

	; This is the only way autoit will allow us to dynamically use parameters provided.
	_Io_FuncGetArgs($aParams, @NumParams - 3)

	; Prep package (Serialization)
	Local $package = _Io_PrepPackage($sEventName, $aParams)

	Local $bytesSent = 0

	For $subscribedSocket In $g__io_SubscriberRooms.item($sDesiredRoomName).keys()
		$bytesSent += _Io_sendPackage($subscribedSocket, $package)
	Next

	Return $bytesSent

EndFunc   ;==>_Io_BroadcastToRoom
