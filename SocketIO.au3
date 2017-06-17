#cs
Copyright (c) 2017 TarreTarreTarre <tarre.islam@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#ce
#include-once
Global const $__c_ver = "0.1";Do not edit
Global Enum $__e_io_SERVER, $__e_io_CLIENT
Global $__g_io_sockets[1] = [0], $__g_io_extended_sockets[1] = [0], $__g_io_whoami, $__g_io_max_dead_sockets_count = 0, $__g_io_events[1] = [0], $__g_io_mySocket, $__g_io_dead_sockets_count = 0, $__g_io_conn_ip, $__g_io_conn_port, $__g_io_AutoReconnect = False, $__g_io_TransportCooldown = Null


; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Listen
; Description ...:
; Syntax ........: _Io_Listen($iPort[, $iAddress = @IPAddress1[, $iMaxPendingConnections = Default[,
;                  $iMaxDeadSocketsBeforeTidy = 1000]]])
; Parameters ....: $iPort               - an integer value.
;                  $iAddress            - [optional] an integer value. Default is @IPAddress1.
;                  $iMaxPendingConnections- [optional] an integer value. Default is Default.
;                  $iMaxDeadSocketsBeforeTidy- [optional] an integer value. Default is 1000.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Listen($iPort, $iAddress = @IPAddress1, $iMaxPendingConnections = Default, $iMaxDeadSocketsBeforeTidy = 1000)
	If Not __Io_Init() Then Return SetError(1, 0, Null)
	Local $socket = TCPListen($iAddress, $iPort, $iMaxPendingConnections)
	If @error Then Return SetError(2, 0, Null)
	$__g_io_whoami = $__e_io_SERVER
	$__g_io_mySocket = $socket
	$__g_io_max_dead_sockets_count = $iMaxDeadSocketsBeforeTidy
	Return $socket
EndFunc   ;==>_Io_Listen

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Connect
; Description ...:
; Syntax ........: _Io_Connect($iAddress, $iPort[, $bAutoReconnect = False])
; Parameters ....: $iAddress            - an integer value.
;                  $iPort               - an integer value.
;                  $bAutoReconnect      - [optional] a boolean value. Default is False.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Connect($iAddress, $iPort, $bAutoReconnect = False)
	If Not __Io_Init() Then Return SetError(1, 0, Null)
	Local $socket = TCPConnect($iAddress, $iPort)
	If @error Then Return SetError(@error, 0, Null)
	$__g_io_whoami = $__e_io_CLIENT
	$__g_io_mySocket = $socket
	$__g_io_conn_ip = $iAddress
	$__g_io_conn_port = $iPort
	$__g_io_AutoReconnect = $bAutoReconnect
	Return $socket
EndFunc   ;==>_Io_Connect

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Reconnect
; Description ...:
; Syntax ........: _Io_Reconnect(ByRef $socket)
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Reconnect(ByRef $socket)
	$socket = _Io_Connect($__g_io_conn_ip, $__g_io_conn_port)
	Return $socket
EndFunc   ;==>_Io_Reconnect

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_LoopFacade
; Description ...:
; Syntax ........: _Io_LoopFacade()
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_LoopFacade()
	_Io_Loop($__g_io_mySocket)
EndFunc   ;==>_Io_LoopFacade

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Loop
; Description ...:
; Syntax ........: _Io_Loop(Byref $socket)
; Parameters ....: $socket              - [in/out] a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Loop(ByRef $socket)
	Local Static $timer = TimerInit()
	Local $recvd, $aParams = Null

	Switch $__g_io_whoami
		Case $__e_io_SERVER

			; -------------
			;	Check for incomming connections
			; -------------

			Local $connectedSocket = TCPAccept($socket)

			If $connectedSocket <> -1 Then
				; Save the regular socket
				__Io_Push($__g_io_sockets, $connectedSocket)

				; Create an extended socket with more info, but in an separate array
				Local $aExtendedSocket = __Io_createExtendedSocket($connectedSocket)

				__Io_Push($__g_io_extended_sockets, $aExtendedSocket)

				; Fire connection event
				__Io_FireEvent($connectedSocket, $aParams, "connection")
			EndIf

			; -------------
			;	Check client alive-status and see if any data was transmitted to the server
			; -------------
			Local $aDeadSockets[1] = [0]

			For $i = 1 To $__g_io_sockets[0]
				Local $client_socket = $__g_io_sockets[$i]

				; Ignore dead sockets
				If $client_socket == Null Then ContinueLoop

				$recvd = TCPRecv($client_socket, 2048, 1)

				; Check if client is offline
				If @error Then
					; Add socket ID to array of dead sockets
					; After the events are fired, we gonna mark it for deletion
					__Io_Push($aDeadSockets, $i)

					; Incr dead count
					$__g_io_dead_sockets_count += 1

					ContinueLoop
				EndIf

				; Collect all Processed data, so we can invoke them all at once instead of one by one
				If StringLen($recvd) Then
					__Io_handleRecvdData($client_socket, $recvd)
				EndIf
			Next


			; -------------
			;	Handle all dead sockets
			; -------------

			For $i = 1 To $aDeadSockets[0]
				Local $aDeadSocket_index = $aDeadSockets[$i]
				Local $deadSocket = $__g_io_sockets[$aDeadSocket_index]

				; Fire event
				__Io_FireEvent($deadSocket, $aParams, "disconnect")

				; Mark socket as dead.
				$__g_io_sockets[$aDeadSocket_index] = Null
			Next

			; -------------
			;	Determine if we need to tidy up (Remove all dead sockets)
			; -------------

			If $__g_io_dead_sockets_count >= $__g_io_max_dead_sockets_count Then
				__Io_TidyUp()
			EndIf



		Case $__e_io_CLIENT
			; -------------
			;	Recv data from server
			; -------------

			$recvd = TCPRecv($socket, 2048, 1)

			; -------------
			;	Check server alive-status
			; -------------

			If @error Then
				__Io_FireEvent($socket, $aParams, "disconnect")

				If $__g_io_AutoReconnect Then
					_Io_Reconnect($socket)
				EndIf
			EndIf

			; -------------
			;	Parse incomming data
			; -------------

			If StringLen($recvd) Then
				__Io_handleRecvdData($socket, $recvd)
			EndIf

	EndSwitch
	Return 0xB00B5
EndFunc   ;==>_Io_Loop

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_On
; Description ...:
; Syntax ........: _Io_On(Const $sEventName, Const $fCallback)
; Parameters ....: $sEventName          - [const] a string value.
;                  $fCallback           - [const] a floating point value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_On(Const $sEventName, Const $fCallback)
	Local $eventData = [$sEventName, $fCallback]
	__Io_Push($__g_io_events, $eventData)
EndFunc   ;==>_Io_On

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_getSocketsCount
; Description ...:
; Syntax ........: _Io_getSocketsCount()
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_getSocketsCount()
	Return $__g_io_sockets[0]
EndFunc   ;==>_Io_getSocketsCount

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_getDeadSocketCount
; Description ...:
; Syntax ........: _Io_getDeadSocketCount()
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_getDeadSocketCount()
	Return $__g_io_dead_sockets_count
EndFunc   ;==>_Io_getDeadSocketCount

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Emit
; Description ...:
; Syntax ........: _Io_Emit(Byref $socket, $sEventName[, $p1 = Default[, $p2 = Default[, $p3 = Default[, $p4 = Default[,
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
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Emit(ByRef $socket, $sEventName, $p1 = Default, $p2 = Default, $p3 = Default, $p4 = Default, $p5 = Default, $p6 = Default, $p7 = Default, $p8 = Default, $p9 = Default, $p10 = Default)

	; No goof names allowed
	If Not StringRegExp($sEventName, "^[a-zA-Z 0-9_.:-]+$") Then Return SetError(1, 0, Null)

	; What to send
	Local $aParams = [$p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10]

	; Create binary from all data
	Local $binaryRequest = __Io_createBinaryRequestFromArray($sEventName, $aParams, @NumParams)

	; attempt to send request
	__Io_TransportData($socket, $binaryRequest)

EndFunc   ;==>_Io_Emit

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Broadcast
; Description ...:
; Syntax ........: _Io_Broadcast(Byref $socket, $sEventName[, $p1 = Default[, $p2 = Default[, $p3 = Default[, $p4 = Default[,
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
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Broadcast(ByRef $socket, $sEventName, $p1 = Default, $p2 = Default, $p3 = Default, $p4 = Default, $p5 = Default, $p6 = Default, $p7 = Default, $p8 = Default, $p9 = Default, $p10 = Default)
	; No goof names allowed
	If Not StringRegExp($sEventName, "^[a-zA-Z 0-9_.:-]+$") Then Return SetError(1, 0, Null)

	; What to send
	Local $aParams = [$p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10]

	; Prepare request
	Local $binaryRequest = __Io_createBinaryRequestFromArray($sEventName, $aParams, @NumParams)

	For $i = 1 To $__g_io_sockets[0]
		Local $client_socket = $__g_io_sockets[$i]

		; Ignore dead sockets and "self"
		If $client_socket == Null Or $socket == $client_socket Then ContinueLoop

		; Send da package
		__Io_TransportData($client_socket, $binaryRequest)

	Next
EndFunc   ;==>_Io_Broadcast

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_BroadcastToAll
; Description ...:
; Syntax ........: _Io_BroadcastToAll(Byref $socket, $sEventName[, $p1 = Default[, $p2 = Default[, $p3 = Default[, $p4 = Default[,
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
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_BroadcastToAll(ByRef $socket, $sEventName, $p1 = Default, $p2 = Default, $p3 = Default, $p4 = Default, $p5 = Default, $p6 = Default, $p7 = Default, $p8 = Default, $p9 = Default, $p10 = Default)
	; No goof names allowed
	If Not StringRegExp($sEventName, "^[a-zA-Z 0-9_.:-]+$") Then Return SetError(1, 0, Null)

	; What to send
	Local $aParams = [$p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10]

	; Prepare request
	Local $binaryRequest = __Io_createBinaryRequestFromArray($sEventName, $aParams, @NumParams)

	For $i = 1 To $__g_io_sockets[0]
		Local $client_socket = $__g_io_sockets[$i]

		; Ignore dead sockets only
		If $client_socket == Null Then ContinueLoop

		; Send da package
		__Io_TransportData($client_socket, $binaryRequest)

	Next
EndFunc   ;==>_Io_BroadcastToAll

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_socketGetProperty
; Description ...:
; Syntax ........: _Io_socketGetProperty(Byref $socket[, $sProp = Default])
; Parameters ....: $socket              - [in/out] a string value.
;                  $sProp               - [optional] a string value. Default is Default.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_socketGetProperty(ByRef $socket, $sProp = Default)
	; Get property from socket
	For $i = 1 To $__g_io_sockets[0]

		If $__g_io_sockets[$i] == $socket Then
			Local $aExtendedSocket = $__g_io_extended_sockets[$i]
			; Return all
			If $sProp == Default Then Return $aExtendedSocket

			; Return specific
			Switch $sProp
				Case "ip"
					Return $aExtendedSocket[1]
				Case "date"
					Return $aExtendedSocket[2]
				Case "room"
					Return $aExtendedSocket[3]
			EndSwitch

		EndIf
	Next

	Return SetError(1, 0, Null)
EndFunc   ;==>_Io_socketGetProperty

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_getVer
; Description ...:
; Syntax ........: _Io_getVer()
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_getVer()
	Return $__c_ver
EndFunc
; ~ Internal functions
Func __Io_TidyUp()
	; Copy
	Local $aTmp = $__g_io_sockets
	Local $aTmpExtended = $__g_io_extended_sockets
	; Empty
	Global $__g_io_sockets[1] = [0]
	Global $__g_io_extended_sockets[1] = [0]

	; Rebuild
	For $i = 1 To $aTmp[0]
		Local $socket = $aTmp[$i]
		Local $aExtendedSocket = $aTmpExtended[$i]
		If $socket == Null Then ContinueLoop

		__Io_Push($__g_io_sockets, $socket)
		__Io_Push($__g_io_extended_sockets, $aExtendedSocket)
	Next

	; Reset
	$__g_io_dead_sockets_count = 0

EndFunc   ;==>__Io_TidyUp

Func __Io_FireEvent(ByRef $socket, ByRef $r_params, $sEventName)
	For $i = 1 To $__g_io_events[0]
		Local $eventData = $__g_io_events[$i]
		Local $fCallback = $eventData[1]

		If $eventData[0] == $sEventName Then
			Return __Io_InvokeCallback($socket, $r_params, $fCallback)
		EndIf
	Next

EndFunc   ;==>__Io_FireEvent

Func __Io_InvokeCallback(ByRef $socket, ByRef $r_params, Const $fCallback)

	Local $x = IsArray($r_params) ? $r_params[0] : 0

	Switch $x
		Case 0
			$fCallback($socket)
		Case 1
			$fCallback($socket, $r_params[1])
		Case 2
			$fCallback($socket, $r_params[1], $r_params[2])
		Case 3
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3])
		Case 4
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4])
		Case 5
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5])
		Case 6
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6])
		Case 7
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6], $r_params[7])
		Case 8
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6], $r_params[7], $r_params[8])
		Case 9
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6], $r_params[7], $r_params[8], $r_params[9])
		Case 10
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6], $r_params[7], $r_params[8], $r_params[9], $r_params[10])
	EndSwitch

EndFunc   ;==>__Io_InvokeCallback

Func __Io_createBinaryRequestFromArray(ByRef $sEventName, ByRef $aData, Const $NumParams)

	; Build da requezt
	Local $request = $sEventName & @LF

	; append parameters
	For $i = 3 To $NumParams
		$request &= __Io_data2stringary($aData[$i - 3]) & ($i < $NumParams ? @LF : "")
	Next

	; Append a last @LF, since two packets can be read as ONE, if they are sent tightly
	$request &= @LF

	; Return binary
	Return StringToBinary($request)
EndFunc   ;==>__Io_createBinaryRequestFromArray

Func __Io_getDataArrayFromBinaryRequest(ByRef $recvd)
	; Convert to string
	Local $package = BinaryToString($recvd)

	; Strip the last @LF that was appended in emit mode
	$package = StringRegExpReplace($package, "(.*)\" & @LF & "$", "$1")

	; Split the package
	Local $aLines = StringSplit($package, @LF)


	; Validate and evaluate the meaning of life ~  /Music plays

	Local $products[1] = [0]

	Local $iMax = $aLines[0]

	For $i = 1 To $iMax

		Local $c = $aLines[$i]

		If Not StringRegExp($c, "\|") Then
			;Event name
			Local $params = __Io_getParamsFromBinaryDataArray($aLines, $i + 1 < $iMax ? $i + 1 : $iMax) ; TODO check if next is even possible
			Local $product = [$c, $params]
			__Io_Push($products, $product)

		EndIf

	Next

	Return $products

EndFunc   ;==>__Io_getDataArrayFromBinaryRequest

Func __Io_getParamsFromBinaryDataArray(ByRef $aLines, $s) ;VarGetType|data
	; This could get erased with some Regex instead, but im lazy LOLQQQQ
	Local $a[1] = [0], $c, $n, $t = $aLines[0], $cur

	For $i = $s To $t
		$cur = $aLines[$i]

		; Only if its not an event
		If Not StringRegExp($cur, "\|") Then ExitLoop
		__Io_Push($a, __Io_stringary2data($cur))

	Next

	Return $a
EndFunc   ;==>__Io_getParamsFromBinaryDataArray

Func __Io_handleRecvdData(ByRef $socket, ByRef $recvd)
	Local $products = __Io_getDataArrayFromBinaryRequest($recvd) ;0 event; 1 array of params
	For $w = 1 To $products[0]
		Local $product = $products[$w]

		Local $sEventName = $product[0]
		Local $aParams = $product[1]

		__Io_FireEvent($socket, $aParams, $sEventName)
	Next
EndFunc   ;==>__Io_handleRecvdData

Func __Io_data2stringary($data)
	Local $VarGetType = VarGetType($data)

	; Prepare data (If needed
	Switch $VarGetType
		Case 'String'
			$data = StringToBinary($data); Because @LF can destroy everything!;StringReplace($data, @LF, "~{%LF%}~")
		Case 'Bool'
			$VarGetType = $data ? 'Bool:true' : 'Bool:false'
		Case 'Array'
			;$data = __Io_Implode($data)
	EndSwitch

	Return (StringFormat("%s|%s", $VarGetType, $data))
EndFunc   ;==>__Io_data2stringary

Func __Io_stringary2data($data)
	;$data = BinaryToString($data);
	Local $d = StringRegExp($data, "([^|]+)\|(.*)", 1)

	If Not IsArray($d) Then Return SetError(1, 0, 0xDEADB33F)

	Switch $d[0]
		Case "Int32"
			Return Number($d[1])
		Case "Ptr"
			Return Ptr($d[1])
		Case "Float"
			Return Number($d[1])
		Case "Bool:true"
			Return True
		Case "Bool:false"
			Return False
		Case "Keyword"
			Return Null
		Case "Array"
			Return "Arrays are not supported yet";__Io_Explode($d[1])
		Case Else ; String
			Return BinaryToString($d[1]); StringReplace($d[1], "~{%LF%}~", @LF)
	EndSwitch

EndFunc   ;==>__Io_stringary2data

Func __Io_TransportData(ByRef $socket, ByRef $data)
	TCPSend($socket, $data)
EndFunc   ;==>__Io_TransportData

Func __Io_createExtendedSocket(ByRef $socket) ;Actual socket, ip address, date, room
	Local $aExtendedSocket = [$socket, __Io_SocketToIP($socket), StringFormat("%s-%s-%s %s:%s:%s", @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC), Null]
	Return $aExtendedSocket
EndFunc   ;==>__Io_createExtendedSocket

Func __Io_SocketToIP(ByRef $socket) ;ty javiwhite

	Local Const $hDLL = "Ws2_32.dll"
	Local $structName = DllStructCreate("short;ushort;uint;char[8]")
	Local $sRet = DllCall($hDLL, "int", "getpeername", "int", $socket, "ptr", DllStructGetPtr($structName), "int*", DllStructGetSize($structName))
	If Not @error Then
		$sRet = DllCall($hDLL, "str", "inet_ntoa", "int", DllStructGetData($structName, 3))
		If Not @error Then Return $sRet[0]
	EndIf
	Return "~unk~" ;Something went wrong, return an invalid IP
EndFunc   ;==>__Io_SocketToIP

Func __Io_Init()
	OnAutoItExitRegister("__Io_Shutdown")
	Return TCPStartup()
EndFunc   ;==>__Io_Init

Func __Io_Shutdown()
	TCPShutdown()
EndFunc   ;==>__Io_Shutdown

Func __Io_Push(ByRef $a, $v)

	ReDim $a[$a[0] + 2]
	$a[$a[0] + 1] = $v
	$a[0] += 1
	Return $a[0]
EndFunc   ;==>__Io_Push

Func __Io_Implode(ByRef $a, $glue = "~{%AS%}~")
	Local $sRes = "", $size = UBound($a)

	For $i = 0 To $size
		$sRes &= $a[$i] & $i < $size ? "|" : ""
	Next

	Return $sRes
EndFunc

Func __Io_Explode($str, $glue = "~{%AS%}~")
	Return StringSplit(StringReplace($str, $glue, @LF), @LF, 2)
EndFunc