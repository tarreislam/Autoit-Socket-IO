#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Emit
; Description ...: Emit an event to a given $socket. Mostly used for server to client and client to server communication.
; Syntax ........: _Io_Emit(Const $socket, $sEventName[, $p1 = Default[, $p2 = Default[, $p3 = Default[, $p4 = Default[,
;                  $p5 = Default[, $p6 = Default[, $p7 = Default[, $p8 = Default[, $p9 = Default[, $p10 = Default]]]]]]]]]])
; Parameters ....: $socket              - [in/out] a string value.
;                  $sEventName          - a string value.
;                  $p1                  - [optional] a pointer value. Default is Default.
;                  $p2                  - [optional] a pointer value. Default is Default.
;                  $p3                  - [optional] a pointer value. Default is Default.
;                  $p4                  - [optional] a pointer value. Default is Default.
;                  $p5                  - [optional] a pointer value. Default is Default.
;                  $p6                  - [optional] a pointer value. Default is Default.
;                  $p7                  - [optional] a pointer value. Default is Default.
;                  $p8                  - [optional] a pointer value. Default is Default.
;                  $p9                  - [optional] a pointer value. Default is Default.
;                  $p10                 - [optional] a pointer value. Default is Default.
; Return values .: Integer. Bytes sent
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: To pass more than 16 parameters, a special array can be passed in lieu of individual parameters. This array must have its first element set to "CallArgArray" and elements 1 - n will be passed as separate arguments to the function. If using this special array, no other arguments can be passed
; Related .......: _Io_Broadcast, _Io_BroadcastToAll, _Io_BroadcastToRoom
; Link ..........:
; Example .......: No
; ===============================================================================================================================

Func _Io_Emit(Const $socket, $sEventName, $p1 = Default, $p2 = Default, $p3 = Default, $p4 = Default, $p5 = Default, $p6 = Default, $p7 = Default, $p8 = Default, $p9 = Default, $p10 = Default, $p11 = Default, $p12 = Default, $p13 = Default, $p14 = Default, $p15 = Default, $p16 = Default)

	; What to send
	Local $aParams = [$p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10, $p11, $p12, $p13, $p14, $p15, $p16]

	; This is the only way autoit will allow us to dynamically use parameters provided.
	_Io_FuncGetArgs($aParams, @NumParams - 2)

	; Prep package (Serialization)
	Local $package = _Io_PrepPackage($sEventName, $aParams)

	; Send package (TcpSend)
	Return _Io_sendPackage($socket, $package)

EndFunc   ;==>_Io_Emit