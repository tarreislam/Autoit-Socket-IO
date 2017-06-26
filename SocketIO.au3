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
#include <Crypt.au3>
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7
Global Const $__c_ver = "1.3.0"
Global Enum $__e_io_SERVER, $__e_io_CLIENT
Global $__g_io_isActive = Null, $__g_io_vCryptKey = Null, $__g_io_vCryptAlgId = Null, $__g_io_sockets[1] = [0], $__g_io_extended_sockets[1] = [0], $__g_io_socket_rooms[1] = [0], $__g_io_whoami, $__g_io_max_dead_sockets_count = 0, $__g_io_events[1] = [0], $__g_io_mySocket, $__g_io_dead_sockets_count = 0, $__g_io_conn_ip, $__g_io_conn_port, $__g_io_AutoReconnect = False, $__g_io_nPacketSize = Null, $__g_io_nMaxConnections = Null


; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Listen
; Description ...:
; Syntax ........: _Io_Listen($iPort[, $iAddress = @IPAddress1[, $iMaxPendingConnections = Default[,
;                  $iMaxDeadSocketsBeforeTidy = 1000[, $iMaxConnections = 100000]]]])
; Parameters ....: $iPort               - an integer value.
;                  $iAddress            - [optional] an integer value. Default is @IPAddress1.
;                  $iMaxPendingConnections- [optional] an integer value. Default is Default.
;                  $iMaxDeadSocketsBeforeTidy- [optional] an integer value. Default is 1000.
;                  $iMaxConnections     - [optional] an integer value. Default is 100000.
; Return values .: None
; Author ........:  TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Listen($iPort, $iAddress = @IPAddress1, $iMaxPendingConnections = Default, $iMaxDeadSocketsBeforeTidy = 1000, $iMaxConnections = 100000)
	If Not __Io_Init() Then Return SetError(1, 0, Null)
	Local $socket = TCPListen($iAddress, $iPort, $iMaxPendingConnections)
	If @error Then Return SetError(2, 0, Null)
	; Set default settings
	_Io_setRecvPackageSize()
	$__g_io_whoami = $__e_io_SERVER
	$__g_io_mySocket = $socket
	$__g_io_max_dead_sockets_count = $iMaxDeadSocketsBeforeTidy
	$__g_io_nMaxConnections = $iMaxConnections
	$__g_io_isActive = True
	Global $__g_io_sockets[$iMaxConnections + 1] = [0]
	Global $__g_io_extended_sockets[$iMaxConnections + 1] = [0]
	Global $__g_io_socket_rooms[$iMaxConnections + 1] = [0]
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
Func _Io_Connect($iAddress, $iPort, $bAutoReconnect = True)
	If Not __Io_Init() Then Return SetError(1, 0, Null)
	Local $socket = TCPConnect($iAddress, $iPort)
	If @error Then Return SetError(@error, 0, Null)
	; Set default settings
	_Io_setRecvPackageSize()
	$__g_io_whoami = $__e_io_CLIENT
	$__g_io_mySocket = $socket
	$__g_io_conn_ip = $iAddress
	$__g_io_conn_port = $iPort
	$__g_io_AutoReconnect = $bAutoReconnect
	$__g_io_isActive = True
	Return $socket
EndFunc   ;==>_Io_Connect

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_EnableEncryption
; Description ...:
; Syntax ........: _Io_EnableEncryption($sFileOrKey)
; Parameters ....: $sFileOrKey          - a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_EnableEncryption($sFileOrKey, $CryptAlgId = $CALG_AES_256)
	Local Const $test_string = "2 legit 2 quit"
	If FileExists($sFileOrKey) Then
		$sFileOrKey = FileRead($sFileOrKey)
		If @error Then
			SetExtended(@error)
			Return SetError(1, 0, Null)
		EndIf
	EndIf

	; Attempt to init Cryp
	_Crypt_Startup()
	If @error Then
		SetExtended(@error)
		Return SetError(2, 0, Null)
	EndIf

	; Validate settings
	Local $test_encrypt_data = _Crypt_EncryptData($test_string, $sFileOrKey, $CryptAlgId)

	If @error Then
		SetExtended(@error)
		Return SetError(3, 0, Null)
	EndIf

	Local $test_decrypt_data = _Crypt_DecryptData($test_encrypt_data, $sFileOrKey, $CryptAlgId)

	If @error Then
		SetExtended(@error)
		Return SetError(4, 0, Null)
	EndIf

	; Test encryption
	If BinaryToString($test_decrypt_data) == $test_string Then
		$__g_io_vCryptKey = $sFileOrKey
		$__g_io_vCryptAlgId = $CryptAlgId
		Return True
	EndIf

	Return SetError(5, 0, Null)
EndFunc   ;==>_Io_EnableEncryption

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_setRecvPackageSize
; Description ...:
; Syntax ........: _Io_setRecvPackageSize([$nPackageSize = 2048])
; Parameters ....: $nPackageSize        - [optional] a general number value. Default is 2048.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_setRecvPackageSize($nPackageSize = 4096)
	$__g_io_nPacketSize = $nPackageSize
EndFunc   ;==>_Io_setRecvPackageSize

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
; Name ..........: _Io_Subscribe
; Description ...:
; Syntax ........: _Io_Subscribe(Byref $socket, $sRoomName)
; Parameters ....: $socket              - [in/out] a string value.
;                  $sRoomName           - a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Subscribe(ByRef $socket, $sRoomName)
	__Io_Push2x($__g_io_socket_rooms, $socket, $sRoomName, False)
EndFunc   ;==>_Io_Subscribe

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Unsubscribe
; Description ...:
; Syntax ........: _Io_Unsubscribe(Byref $socket, $sRoomName)
; Parameters ....: $socket              - [in/out] a string value.
;                  $sRoomName           - a string value.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Unsubscribe(ByRef $socket, $sDesiredRoomName = Null)

	For $i = 1 To $__g_io_socket_rooms[0] Step +2
		If $__g_io_socket_rooms[$i] == $socket And ($__g_io_socket_rooms[$i + 1] == $sDesiredRoomName Or $sDesiredRoomName == Null) Then
			$__g_io_socket_rooms[$i] = Null
			$__g_io_socket_rooms[$i + 1] = Null
		EndIf
	Next

EndFunc   ;==>_Io_Unsubscribe

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Disconnect
; Description ...:
; Syntax ........: _Io_Disconnect([$socket = Null])
; Parameters ....: $socket              - [optional] a string value. Default is Null.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: The difference with this method of disconnecting and disconnecting by mistake, is that we cause the loops and facade to be purged, and the user will have to listen\connect again
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_Disconnect($socket = Null)
	If $__g_io_whoami == $__e_io_SERVER And @NumParams == 1 Then
		Return TCPCloseSocket($socket)
	EndIf
	$__g_io_isActive = False
	AdlibUnRegister("_Io_LoopFacade")
	__Io_Shutdown()
	Return True
EndFunc   ;==>_Io_Disconnect

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
	Local $package, $aParams = Null

	Switch $__g_io_whoami
		Case $__e_io_SERVER

			; -------------
			;	Check for incomming connections
			; -------------

			Local $connectedSocket = TCPAccept($socket)

			If $connectedSocket <> -1 Then

			; Check if we have room for another one (Even dead sockets takes spaces, so therefore were not including $__g_io_dead_sockets_count)
				If $__g_io_sockets[0] + 1 <= $__g_io_nMaxConnections Then
					; Save the regular socket
					__Io_Push($__g_io_sockets, $connectedSocket, False)

					; Create an extended socket with more info, but in an separate array
					Local $aExtendedSocket = __Io_createExtendedSocket($connectedSocket)

					__Io_Push($__g_io_extended_sockets, $aExtendedSocket, False)

					; Fire connection event
					__Io_FireEvent($connectedSocket, $aParams, "connection")
				Else
					; Close socket because were full!
					_Io_Disconnect($connectedSocket)
				EndIf
			EndIf

			; -------------
			;	Check client alive-status and see if any data was transmitted to the server
			; -------------
			Local $aDeadSockets[1] = [0]

			For $i = 1 To $__g_io_sockets[0]
				Local $client_socket = $__g_io_sockets[$i]

				; Ignore dead sockets
				If Not $client_socket > 0 Then ContinueLoop

				$package = __Io_RecvPackage($client_socket)

				; Check if client is offline
				If @error Then
					; Add socket ID to array of dead sockets

					__Io_Push($aDeadSockets, $i)

					; Incr dead count
					$__g_io_dead_sockets_count += 1

					ContinueLoop
				EndIf

				; Collect all Processed data, so we can invoke them all at once instead of one by one
				If $package Then
					__Io_handlePackage($client_socket, $package)
				EndIf
			Next

			; -------------
			;	Handle all dead sockets
			; -------------

			For $i = 1 To $aDeadSockets[0]
				Local $aDeadSocket_index = $aDeadSockets[$i]
				Local $deadSocket = $__g_io_sockets[$aDeadSocket_index]

				; Unsubscribe them from everything
				_Io_Unsubscribe($deadSocket)

				; Fire event
				__Io_FireEvent($deadSocket, $aParams, "disconnect")

				; Mark socket as dead.
				$__g_io_sockets[$aDeadSocket_index] = Null
			Next

			; -------------
			;	Determine if we need to tidy up (Remove all dead sockets)
			; -------------
			If $__g_io_max_dead_sockets_count > 0 And $__g_io_dead_sockets_count >= $__g_io_max_dead_sockets_count Then
				_Io_TidyUp()
			EndIf

		Case $__e_io_CLIENT
			; -------------
			;	Recv data from server
			; -------------

			$package = __Io_RecvPackage($socket)

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

			If $package Then
				__Io_handlePackage($socket, $package)
			EndIf

	EndSwitch

	Return $__g_io_isActive
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
Func _Io_Emit(ByRef $socket, $sEventName, $p1 = Default, $p2 = Default, $p3 = Default, $p4 = Default, $p5 = Default, $p6 = Default, $p7 = Default, $p8 = Default, $p9 = Default, $p10 = Default, $p11 = Default, $p12 = Default, $p13 = Default, $p14 = Default, $p15 = Default, $p16 = Default)

	; No goof names allowed
	If Not __Io_ValidEventName($sEventName) Then Return SetError(1, 0, Null)

	; What to send
	Local $aParams = [$p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10, $p11, $p12, $p13, $p14, $p15, $p16]

	; Prepare package
	Local $package = __Io_createPackage($sEventName, $aParams, @NumParams)

	; attempt to send request
	__Io_TransportPackage($socket, $package)

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
Func _Io_Broadcast(ByRef $socket, $sEventName, $p1 = Default, $p2 = Default, $p3 = Default, $p4 = Default, $p5 = Default, $p6 = Default, $p7 = Default, $p8 = Default, $p9 = Default, $p10 = Default, $p11 = Default, $p12 = Default, $p13 = Default, $p14 = Default, $p15 = Default, $p16 = Default)

	; No goof names allowed
	If Not __Io_ValidEventName($sEventName) Then Return SetError(1, 0, Null)

	; What to send
	Local $aParams = [$p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10, $p11, $p12, $p13, $p14, $p15, $p16]

	; Prepare package
	Local $package = __Io_createPackage($sEventName, $aParams, @NumParams)

	For $i = 1 To $__g_io_sockets[0]
		Local $client_socket = $__g_io_sockets[$i]

		; Ignore dead sockets and "self"
		If Not $client_socket > 0 Or $socket == $client_socket Then ContinueLoop

		; Send da package
		__Io_TransportPackage($client_socket, $package)

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
Func _Io_BroadcastToAll(ByRef $socket, $sEventName, $p1 = Default, $p2 = Default, $p3 = Default, $p4 = Default, $p5 = Default, $p6 = Default, $p7 = Default, $p8 = Default, $p9 = Default, $p10 = Default, $p11 = Default, $p12 = Default, $p13 = Default, $p14 = Default, $p15 = Default, $p16 = Default)
	#forceref $socket
	; No goof names allowed
	If Not __Io_ValidEventName($sEventName) Then Return SetError(1, 0, Null)

	; What to send
	Local $aParams = [$p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10, $p11, $p12, $p13, $p14, $p15, $p16]

	; Prepare package
	Local $package = __Io_createPackage($sEventName, $aParams, @NumParams)

	For $i = 1 To $__g_io_sockets[0]
		Local $client_socket = $__g_io_sockets[$i]

		; Ignore dead sockets only
		If Not $client_socket > 0 Then ContinueLoop

		; Send da package
		__Io_TransportPackage($client_socket, $package)

	Next

EndFunc   ;==>_Io_BroadcastToAll

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_BroadcastToRoom
; Description ...:
; Syntax ........: _Io_BroadcastToRoom(Byref $socket, $sDesiredRoomName, $sEventName[, $p1 = Default[, $p2 = Default[, $p3 = Default[,
;                  $p4 = Default[, $p5 = Default[, $p6 = Default[, $p7 = Default[, $p8 = Default[, $p9 = Default[,
;                  $p10 = Default[, $p11 = Default[, $p12 = Default[, $p13 = Default[, $p14 = Default[, $p15 = Default[,
;                  $p16 = Default]]]]]]]]]]]]]]]])
; Parameters ....: $socket              - [in/out] a string value.
;                  $sDesiredRoomName    - a string value.
;                  $sEventName          - a string value.
;                  $p1                  - [optional] a pointer value. Default is Default.
;                  $p16                 - [optional] a pointer value. Default is Default.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_BroadcastToRoom(ByRef $socket, $sDesiredRoomName, $sEventName, $p1 = Default, $p2 = Default, $p3 = Default, $p4 = Default, $p5 = Default, $p6 = Default, $p7 = Default, $p8 = Default, $p9 = Default, $p10 = Default, $p11 = Default, $p12 = Default, $p13 = Default, $p14 = Default, $p15 = Default, $p16 = Default)
	#forceref $socket
	; No goof names allowed
	If Not __Io_ValidEventName($sEventName) Then Return SetError(1, 0, Null)

	; What to send
	Local $aParams = [$p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10, $p11, $p12, $p13, $p14, $p15, $p16]

	; Prepare package
	Local $package = __Io_createPackage($sEventName, $aParams, @NumParams - 1) ; - 1 since we have more params

	For $i = 1 To $__g_io_socket_rooms[0] Step +2
		Local $client_socket = $__g_io_socket_rooms[$i]

		; Ignore dead sockets
		If Not $client_socket > 0 Then ContinueLoop

		Local $sRoomName = $__g_io_socket_rooms[$i + 1]

		; Check if this is the room we want to send to
		If $sDesiredRoomName == $sRoomName Then
			__Io_TransportPackage($client_socket, $package)
		EndIf

	Next

EndFunc   ;==>_Io_BroadcastToRoom

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
EndFunc   ;==>_Io_getVer

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
; Name ..........: _Io_getMaxConnections
; Description ...:
; Syntax ........: _Io_getMaxConnections()
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_getMaxConnections()
	Return $__g_io_nMaxConnections
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_getMaxDeadSocketsCount
; Description ...:
; Syntax ........: _Io_getMaxDeadSocketsCount()
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_getMaxDeadSocketsCount()
	Return $__g_io_max_dead_sockets_count
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_TidyUp
; Description ...:
; Syntax ........: _Io_TidyUp()
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_TidyUp()
	; Copy
	Local $aTmp = $__g_io_sockets
	Local $aTmpExtended = $__g_io_extended_sockets
	Local $aTmpRooms = $__g_io_socket_rooms

	; Reset
	$__g_io_sockets[0] = 0
	$__g_io_extended_sockets[0] = 0
	$__g_io_socket_rooms[0] = 0

	; Rebuild Sockets
	For $i = 1 To $aTmp[0]
		Local $socket = $aTmp[$i]
		Local $aExtendedSocket = $aTmpExtended[$i]
		If Not $socket > 0 Then ContinueLoop

		__Io_Push($__g_io_sockets, $socket, False)
		__Io_Push($__g_io_extended_sockets, $aExtendedSocket, False)
	Next

	; Rebuild subscriptions
	For $i = 1 To $aTmpRooms[0] Step +2
		If $aTmpRooms[$i] = Null Then ContinueLoop
		__Io_Push2x($__g_io_socket_rooms, $aTmpRooms[$i], $aTmpRooms[$i + 1], False)
	Next

	; Reset deathcounter
	$__g_io_dead_sockets_count = 0

EndFunc   ;==>_Io_TidyUp

; ~ Internal functions
Func __Io_FireEvent(ByRef $socket, ByRef $r_params, $sEventName)

	For $i = 1 To $__g_io_events[0]
		Local $eventData = $__g_io_events[$i]
		Local $fCallback = $eventData[1]

		If $eventData[0] == $sEventName Then
			Return __Io_InvokeCallback($socket, $r_params, $fCallback)
		EndIf
	Next

	Return False

EndFunc   ;==>__Io_FireEvent

Func __Io_InvokeCallback(ByRef $socket, ByRef $r_params, Const $fCallback)

	Local Const $x = IsArray($r_params) ? $r_params[0] : 0

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
		Case 11
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6], $r_params[7], $r_params[8], $r_params[9], $r_params[10], $r_params[11])
		Case 12
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6], $r_params[7], $r_params[8], $r_params[9], $r_params[10], $r_params[11], $r_params[12])
		Case 13
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6], $r_params[7], $r_params[8], $r_params[9], $r_params[10], $r_params[11], $r_params[12], $r_params[13])
		Case 14
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6], $r_params[7], $r_params[8], $r_params[9], $r_params[10], $r_params[11], $r_params[12], $r_params[13], $r_params[14])
		Case 15
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6], $r_params[7], $r_params[8], $r_params[9], $r_params[10], $r_params[11], $r_params[12], $r_params[13], $r_params[14], $r_params[15])
		Case 16
			$fCallback($socket, $r_params[1], $r_params[2], $r_params[3], $r_params[4], $r_params[5], $r_params[6], $r_params[7], $r_params[8], $r_params[9], $r_params[10], $r_params[11], $r_params[12], $r_params[13], $r_params[14], $r_params[15], $r_params[16])
	EndSwitch

	Return True

EndFunc   ;==>__Io_InvokeCallback

Func __Io_createPackage(ByRef $sEventName, ByRef $aParams, Const $NumParams)

	; Build da package
	Local $sPackage = $sEventName & ($NumParams > 2 ? @LF : "")

	; append parameters
	For $i = 3 To $NumParams
		$sPackage &= __Io_data2stringary($aParams[$i - 3]) & ($i < $NumParams ? @LF : "")
	Next

	; Strap
	$sPackage &= "#"

	; Return Package
	Return $sPackage
EndFunc   ;==>__Io_createPackage

Func __Io_getProductsFromPackage(ByRef $sPackage)
	; Clean package
	$sPackage = StringRegExpReplace($sPackage, "(?s)(.*)\#$", "$1")

	; Split the package(s) into wrapped products
	Local $aWrapped_products = StringSplit($sPackage, "#")

	Local Const $nWrapped_productSize = $aWrapped_products[0]

	Local $aProducts[$nWrapped_productSize + 1] = [0]
	$aProducts[0] = $nWrapped_productSize

	For $i = 1 To $nWrapped_productSize
		Local $sWrapped_product = $aWrapped_products[$i]

		; Split the products into parts
		Local $aWrapped_parts = StringSplit($sWrapped_product, @LF)

		Local $cnWrapped_size = $aWrapped_parts[0] ;

		Local $sEventName = $aWrapped_parts[1]

		; Translate params
		Local $aParams[$cnWrapped_size]
		$aParams[0] = $cnWrapped_size - 1

		For $y = 2 To $cnWrapped_size
			$aParams[$y - 1] = __Io_stringary2data($aWrapped_parts[$y])
		Next

		; Create finished product
		Local $aProduct = [$sEventName, $aParams]
		$aProducts[$i] = $aProduct
	Next

	Return $aProducts

EndFunc   ;==>__Io_getProductsFromPackage

Func __Io_handlePackage(ByRef $socket, ByRef $sPackage)
	Local $products = __Io_getProductsFromPackage($sPackage) ;0 event; 1 array of params

	For $w = 1 To $products[0]
		Local $product = $products[$w]

		Local $sEventName = $product[0]
		Local $aParams = $product[1]

		__Io_FireEvent($socket, $aParams, $sEventName)
	Next

EndFunc   ;==>__Io_handlePackage

Func __Io_data2stringary($sData, $bArrLoop = False)
	Local $VarGetType = VarGetType($sData)

	; Prepare data (If needed
	Switch $VarGetType
		Case 'String'
			$sData = StringToBinary($sData) ;
		Case 'Bool'
			$VarGetType = $sData ? 'Bool:true' : 'Bool:false'
		Case 'Array'
			Local Const $nSize = UBound($sData)
			Local $sRet = ""

			For $i = 0 To $nSize - 1
				$sRet &= StringToBinary(__Io_data2stringary($sData[$i], True)) & ($i < $nSize - 1 ? "|" : "")
			Next

			If $bArrLoop Then
				Return StringToBinary($sRet)
			Else
				$sData = BinaryToString($sRet)
			EndIf
	EndSwitch

	Return StringFormat("%s|%s", $VarGetType, $sData)
EndFunc   ;==>__Io_data2stringary

Func __Io_stringary2data($sDataInput, $bArrLoop = False)

	; Parse nested arrays
	If StringRegExp($sDataInput, "^0x.*") And $bArrLoop Then

		Local $aNestedArr = StringSplit(BinaryToString($sDataInput), "|", 2)
		Local Const $nSize = UBound($aNestedArr) - 1

		For $i = 0 To $nSize
			$aNestedArr[$i] = __Io_stringary2data(BinaryToString($aNestedArr[$i]), True)
		Next

		Return $aNestedArr
	EndIf

	Local $aDataInput = StringRegExp($sDataInput, "([^|]+)\|(.*)", 1)
	If @error Then Return SetError(1, 0, Null)

	Local Const $sType = $aDataInput[0]
	Local Const $uData = $aDataInput[1]

	Switch $sType
		Case "Int32"
			Return Number($uData)
		Case "Int64"
			Return Number($uData)
		Case "Ptr"
			Return Ptr($uData)
		Case "Binary"
			Return Binary($uData)
		Case "Float"
			Return Number($uData)
		Case "Double"
			Return Number($uData)
		Case "Bool:true"
			Return True
		Case "Bool:false"
			Return False
		Case "Keyword"
			Return Null
		Case "Array"
			Local $aArrayChildren = StringSplit($uData, "|", 2)
			Local Const $cnArrayChildrenSize = UBound($aArrayChildren) - 1

			For $i = 0 To $cnArrayChildrenSize
				$aArrayChildren[$i] = __Io_stringary2data(BinaryToString($aArrayChildren[$i]), True)
			Next

			Return $aArrayChildren
		Case "String"
			Return BinaryToString($uData)
		Case Else
			Return "Cannot parse type: " & $sType
	EndSwitch

EndFunc   ;==>__Io_stringary2data

Func __Io_TransportPackage(ByRef $socket, ByRef $sPackage)
	Local $final_package

	; Check if we should encrypt the data
	If $__g_io_vCryptKey Then
		$final_package = _Crypt_EncryptData($sPackage, $__g_io_vCryptKey, $__g_io_vCryptAlgId)
	Else
		$final_package = StringToBinary($sPackage)
	EndIf


	TCPSend($socket, $final_package)
EndFunc   ;==>__Io_TransportPackage

Func __Io_RecvPackage(ByRef $socket)
	Local $package = TCPRecv($socket, $__g_io_nPacketSize, 1)
	If @error Then Return SetError(@error, 0, "")
	If $package == "" Then Return Null

	; Check if we want to decrypt our data
	If $__g_io_vCryptKey Then
		$package = _Crypt_DecryptData($package, $__g_io_vCryptKey, $__g_io_vCryptAlgId)
	EndIf

	Return BinaryToString($package)
EndFunc   ;==>__Io_RecvPackage

Func __Io_createExtendedSocket(ByRef $socket) ;Actual socket, ip address, date
	Local $aExtendedSocket = [$socket, __Io_SocketToIP($socket), StringFormat("%s-%s-%s %s:%s:%s", @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)]
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

Func __Io_Push(ByRef $a, $v, $bRedim = True)
	If $bRedim Then
		ReDim $a[$a[0] + 2]
	EndIf
	$a[$a[0] + 1] = $v
	$a[0] += 1
	Return $a[0]
EndFunc   ;==>__Io_Push

Func __Io_Push2x(ByRef $a, $v1, $v2, $bRedim = True)
	If $bRedim Then
		ReDim $a[$a[0] + 3]
	EndIf
	$a[$a[0] + 1] = $v1
	$a[$a[0] + 2] = $v2
	$a[0] += 2
	Return $a[0]
EndFunc   ;==>__Io_Push2x

Func __Io_ValidEventName(ByRef $sEventName)
	Return StringRegExp($sEventName, "^[a-zA-Z 0-9_.:-]+$")
EndFunc   ;==>__Io_ValidEventName
