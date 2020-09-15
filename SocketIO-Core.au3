#cs
	Copyright (c) 2017-2020 TarreTarreTarre <tarre.islam@gmail.com>

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
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7
#include-once
#include "Dependencies\Autoit-Serialize-1.0.0\Serialize.au3"
#include "Dependencies\Autoit-Events-1.0.0\Event.au3"
; Load native events
#include "Events\ServerEvents.au3"
#include "Events\ClientEvents.au3"
#include "Events\CommonEvents.au3"
#include <Crypt.au3>
Global Const $g__io_sVer = "4.0.0-beta"
Global Enum $_IO_SERVER, $_IO_CLIENT
; Internal resources
Global $g__io_whoami, _
		$g__io_mySocket, _
		$g__io_isActive, _
		$g__io_vCryptKey, _
		$g__io_vCryptAlgId, _
		$g__io_Sockets, _
		$g__io_Events, _
		$g__io_MiddleWares, _
		$g__io_nPacketSize, _
		$g__io_nMaxPacketSize, _
		$g__io_sOnEventPrefix, _
		$g__io_conn_ip, _
		$g__io_conn_port

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_getVer
; Description ...: Returns the version of the UDF
; Syntax ........: _Io_getVer()
; Parameters ....:
; Return values .: SEMVER string (X.Y.Z)
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: See more on semver @ http://semver.org/
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_getVer()
	Return $g__io_sVer
EndFunc   ;==>_Io_getVer

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_whoAmI
; Description ...: Returns either `$_IO_SERVER` for server or `$_IO_CLIENT` for client
; Syntax ........: _Io_whoAmI([$verbose = false])
; Parameters ....: $verbose             - [optional] a variant value. Default is false.
; Return values .: Bool|String
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: This value is changed when invoking _Io_listen and _Io_Connect. If you set $verbose to `true`. This function retruns either "SERVER" or "CLIENT" instead of the constants
; Related .......: _Io_listen, _Io_Connect, _Io_IsServer, _Io_IsClient
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_WhoAmI($verbose = False)
	Return Not $verbose ? $g__Io_WhoAmI : _Io_IsServer() ? 'SERVER' : 'CLIENT'
EndFunc   ;==>_Io_WhoAmI

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_IsServer
; Description ...: Determines if _Io_WhoAmI() == $_IO_SERVER
; Syntax ........: _Io_IsServer()
; Parameters ....:
; Return values .: Bool
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: This value is changed when invoking _Io_listen and _Io_Connect
; Related .......:  _Io_listen, _Io_Connect, _Io_WhoAmI, _Io_IsClient
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_IsServer()
	Return $g__Io_WhoAmI == $_IO_SERVER
EndFunc   ;==>_Io_IsServer

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_IsClient
; Description ...: Determines if _Io_WhoAmI() == $_IO_CLIENT
; Syntax ........: _Io_IsClient()
; Parameters ....:
; Return values .: Bool
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: This value is changed when invoking _Io_listen and _Io_Connect
; Related .......:   _Io_listen, _Io_Connect, _Io_IsServer, _Io_WhoAmI
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_IsClient()
	Return $g__Io_WhoAmI == $_IO_CLIENT
EndFunc   ;==>_Io_IsClient

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_getSockets
; Description ...:  Returns a scripting Dictionary contain all connected sockets and their properties
; Syntax ........: _Io_getSockets()
; Parameters ....:
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: To access a connected sockets property you can call `_Io_getSockets().item($socketId).item("propName")` Read more in the [Documentation](README.md)
; Related .......:
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_getSockets()
	Return $g__io_Sockets
EndFunc   ;==>_Io_getSockets

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_EnableEncryption
; Description ...: Encrypts data before transmission using AutoIt's Crypt.au3
; Syntax ........: _Io_EnableEncryption($sFileOrKey)
; Parameters ....: $sFileOrKey          - a string value.
; Return values .: `True` if successfully configured. Null + @error if wrongfully configured. Use @Extended to see which type of internal error is thrown.
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: The encryption has to be configured equally on both sides for it to work.
; Related .......:
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_EnableEncryption($sFileOrKey, $CryptAlgId = $CALG_AES_256)
	Local Const $test_string = "2 legit 2 quit"
	If FileExists($sFileOrKey) Then
		$sFileOrKey = FileRead($sFileOrKey)
		If @error Then
			Return SetError(1, @error, Null)
		EndIf
	EndIf

	; Attempt to init Cryp
	_Crypt_Startup()
	If @error Then
		Return SetError(2, @error, Null)
	EndIf

	; Validate settings
	Local $test_encrypt_data = _Crypt_EncryptData($test_string, $sFileOrKey, $CryptAlgId)

	If @error Then
		Return SetError(3, @error, Null)
	EndIf

	Local $test_decrypt_data = _Crypt_DecryptData($test_encrypt_data, $sFileOrKey, $CryptAlgId)

	If @error Then
		Return SetError(4, @error, Null)
	EndIf

	; Test encryption
	If BinaryToString($test_decrypt_data) == $test_string Then
		$g__io_vCryptKey = $sFileOrKey
		$g__io_vCryptAlgId = $CryptAlgId
		Return True
	EndIf

	Return SetError(5, -1, Null)
EndFunc   ;==>_Io_EnableEncryption

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_setRecvPackageSize
; Description ...: Sets the maxlen for [TCPRecv](https://www.autoitscript.com/autoit3/docs/functions/TCPRecv.htm)
; Syntax ........: _Io_setRecvPackageSize([$iPackageSize = 8192])
; Parameters ....: $iPackageSize        - [optional] a general number value. Default is 8192
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......: _Io_SetMaxRecvPackageSize
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_SetRecvPackageSize($iPackageSize = 8192)
	$g__io_nPacketSize = $iPackageSize
EndFunc   ;==>_Io_SetRecvPackageSize

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_setMaxRecvPackageSize
; Description ...: Sets the maxibum binarylen is allowed to be received in a single package.
; Syntax ........: _Io_setMaxRecvPackageSize([$iMaxPackageSize = $g__io_nPacketSize])
; Parameters ....: $iMaxPackageSize     - [optional] a general number value. Default is $g__io_nPacketSize.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: By default if this threshold is exceeded, the `flood` event will be dispatched and the rest of the buffer will be ignored
; Related .......: _Io_SetRecvPackageSize
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_SetMaxRecvPackageSize($iMaxPackageSize = $g__io_nPacketSize)
	$g__io_nMaxPacketSize = $iMaxPackageSize
EndFunc   ;==>_Io_SetMaxRecvPackageSize

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_setOnPrefix
; Description ...: Set the default prefix for `_Io_On` if not passing callback.
; Syntax ........: _Io_setOnPrefix(Const $sPrefix)
; Parameters ....: $sPrefix             - [const] a string value.
; Return values .: @error if invalid prefix
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: only function-friendly names are allowed
; Related .......: _Io_On
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_SetOnPrefix(Const $sPrefix = '_On_')
	If Not StringRegExp($sPrefix, '(?i)[a-z_]+[a-z_0-9]*') Then Return SetError(1)

	$g__io_sOnEventPrefix = $sPrefix
EndFunc   ;==>_Io_SetOnPrefix

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_On
; Description ...: Binds an event
; Syntax ........: _Io_On(Const $sEventName[, $fCallback = Null[, $socket = $g__io_mySocket]])
; Parameters ....: $sEventName          - [Const] a string value.
;                  $fCallback           - [optional] a floating point value. Default is Null.
;                  $socket              - [optional] a string value. Default is $g__io_mySocket.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: If $fCallback is set to null, the function will assume the prefix "_On_" is applied. Eg (_Io_On('test') will look for "Func _On_Test(...)" etc
; Related .......: _Io_SetOnPrefix, _Io_Off
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_On(Const $sEventName, Const $fCallback = Null, $socket = $g__io_mySocket)
	Local $fCallbackName = IsFunc($fCallback) ? FuncName($fCallback) : $fCallback

	If $fCallback == Null And Not StringRegExp($sEventName, '(?i)^[a-z_0-9]*$') Then Return SetError(1)

	If Not $fCallbackName Then
		$fCallbackName = $g__io_sOnEventPrefix & $sEventName
	EndIf

	; Grab the events for a given socket
	Local Const $eventStore = $g__io_Events.item($socket)

	If Not $eventStore.exists($sEventName) Then
		$eventStore.add($sEventName, $fCallbackName)
	EndIf

EndFunc   ;==>_Io_On

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Off
; Description ...: Remove a previously bound event
; Syntax ........: _Io_Off(Const $sEventName[, $socket = $g__io_mySocket])
; Parameters ....: $sEventName          - [const] a string value.
;                  $socket              - [optional] a string value. Default is $g__io_mySocket.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......: _Io_On
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_Off(Const $sEventName, $socket = $g__io_mySocket)
	; Grab the events for a given socket
	Local Const $eventStore = $g__io_Events.item($socket)

	; attempt to delete with and without prefix
	If $eventStore.exists($g__io_sOnEventPrefix & $sEventName) Then
		$eventStore.remove($g__io_sOnEventPrefix & $sEventName)
	ElseIf $eventStore.exists($sEventName) Then
		$eventStore.remove($sEventName)
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_ClearEvents
; Description ...: Removes all bound events for a given socket
; Syntax ........: _Io_ClearEvents([$socket = $g__io_mySocket])
; Parameters ....: $socket              - [optional] a string value. Default is $g__io_mySocket.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Io_ClearEvents($socket = $g__io_mySocket)
	$g__io_Events.item($socket).removeAll()
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Listen
; Description ...: Starts the server for the given port.
; Syntax ........: _Io_Listen($iPort[, $sAddress = @IPAddress1[, $iMaxPendingConnections = Default[,
;                  $iMaxDeadSocketsBeforeTidy = 1000[, $iMaxConnections = 100000]]]])
; Parameters ....: $iPort               - an integer value.
;                  $sAddress            - [optional] a string value. Default is @IPAddress1.
;                  $iMaxPendingConnections- [optional] an integer value. Default is Default.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: _Io_WhoAmI and the other identity roles will work after this function is invoked, even if it fails!
; Related .......:
; Link ..........:
; Example .......: No
; Events ........: _Io_ServerEvents_ListenSucceded, _Io_CommonEvents_Initiated, _Io_CommonEvents_IoRoleDecided
; ===============================================================================================================================
Func _Io_Listen($iPort, $sAddress = @IPAddress1, $iMaxPendingConnections = Default)
	_Event(_Io_ServerEvents_ListenAttempt, $iPort, $sAddress)
	; Change role
	Local Const $oldRole = $g__Io_WhoAmI
	$g__Io_WhoAmI = $_IO_SERVER
	_Event(_Io_CommonEvents_IoRoleDecided, $oldRole, $g__Io_WhoAmI)
	; Attempt to initiate
	If Not __Io_Init() Then
		SetError(1, 0)
		_Event(_Io_ServerEvents_FailedToListen, @error, @extended, $iPort, $sAddress)
		Return Null
	EndIf
	; Try to listen on given port
	Local $socket = TCPListen($sAddress, $iPort, $iMaxPendingConnections)
	If @error Then
		SetError(2, @error)
		_Event(_Io_ServerEvents_FailedToListen, @error, @extended, $iPort, $sAddress)
		Return Null
	EndIf
	; Set app state to server

	$g__io_mySocket = $socket
	$g__io_isActive = True
	$g__io_Sockets = ObjCreate("Scripting.Dictionary")
	; Create event storage for the given socket
	$g__io_Events.add($socket, ObjCreate("Scripting.Dictionary"))

	; #
	_Event_Listen(_Io_ServerEvents_ClientConnected, _Io_ServerEvents_ClientConnected_RegisterSocket)
	_Event_Listen(_Io_ServerEvents_ClientConnected, _Io_ServerEvents_ClientConnected_FireInternalEvent_Connected)
	; #
	_Event_Listen(_Io_ServerEvents_ClientDisconnected, _Io_ServerEvents_ClientDisconnected_UnRegisterSocket)
	_Event_Listen(_Io_ServerEvents_ClientDisconnected, _Io_ServerEvents_ClientDisconnected_FireInternalEvent_Disconnect)
	; #
	_Event_Listen(_Io_CommonEvents_Disconnected, _Io_CommonEvents_Disconnected_UnRegisterEvents)
	_Event_Listen(_Io_CommonEvents_Disconnected, _Io_CommonEvents_Disconnected_ShutDownTcpService)

	_Event_Listen(_Io_CommonEvents_Flooded, _Io_CommonEvents_DisconnectSocket)

	; Dispatch success events
	_Event(_Io_ServerEvents_ListenSucceded, $socket, $iPort, $sAddress)
	_Event(_Io_CommonEvents_Initiated, $socket)

	Return $socket
EndFunc   ;==>_Io_Listen

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Connect
; Description ...: Attempts to connect to a Server.
; Syntax ........: _Io_Connect($sAddress, $iPort[, $bAutoReconnect = True])
; Parameters ....: $sAddress            - a string value.
;                  $iPort               - an integer value.
;                  $bAutoReconnect      - [optional] a boolean value. Default is True.
; Return values .: integer. Null + @error if unable to connect.
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: _Io_WhoAmI and the other identity roles will work after this function is invoked, even if it fails!
; Related .......:
; Link ..........:
; Example .......: No
; Events ........: _Io_ClientEvents_SuccessfullyConnected, _Io_CommonEvents_Initiated, _Io_CommonEvents_IoRoleDecided
; ===============================================================================================================================
Func _Io_Connect($sAddress, $iPort)
	; Change role
	Local Const $oldRole = $g__Io_WhoAmI
	$g__Io_WhoAmI = $_IO_CLIENT
	_Event(_Io_CommonEvents_IoRoleDecided, $oldRole, $g__Io_WhoAmI)
	_Event(_Io_ClientEvents_ConnectionAttempt, $sAddress, $iPort)

	If Not __Io_Init() Then
		SetError(1, 0)
		_Event(_Io_ClientEvents_FailedToConnect, @error, @extended, $sAddress, $iPort)
		Return Null
	EndIf
	Local $socket = TCPConnect($sAddress, $iPort)
	If @error Then
		SetError(2, @error)
		_Event(_Io_ClientEvents_FailedToConnect, @error, @extended, $sAddress, $iPort)
		Return Null
	EndIf
	;Global $g__io_events[1001] = [0]
	$g__io_mySocket = $socket
	$g__io_conn_ip = $sAddress
	$g__io_conn_port = $iPort
	$g__io_isActive = True
	$g__io_Events.add($socket, ObjCreate("Scripting.Dictionary"))

	; # Something happend to the server
	_Event_Listen(_Io_ClientEvents_DisconnectedFromServer, _Io_CommonEvents_Disconnected_UnRegisterEvents)
	_Event_Listen(_Io_ClientEvents_DisconnectedFromServer, _Io_CommonEvents_Disconnected_ShutDownTcpService)
	; # Self disconnection
	_Event_Listen(_Io_CommonEvents_Disconnected, _Io_CommonEvents_Disconnected_UnRegisterEvents)
	_Event_Listen(_Io_CommonEvents_Disconnected, _Io_CommonEvents_Disconnected_ShutDownTcpService)

	_Event(_Io_ClientEvents_SuccessfullyConnected, $socket, $sAddress, $iPort)
	_Event(_Io_CommonEvents_Initiated, $socket)

	Return $socket
EndFunc   ;==>_Io_Connect

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Loop
; Description ...: This is the main event handler for Socket IO.
; Syntax ........: _Io_Loop(Const Byref $socket[, $whoAmI = $g__Io_WhoAmI])
; Parameters ....: $socket              - [in/out and const] a string value.
;                  $whoAmI              - [optional] an unknown value. Default is $g__Io_WhoAmI.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: This function must be used in your scripts main loop or in an AdlibRegister, the speed of your network activity is based on how many times _Io_Loop can be executed
; Related .......:
; Link ..........:
; Example .......: No
; Events ........: _Io_ServerEvents_ClientDisconnected, _Io_CommonEvents_Flooded, _Io_ClientEvents_DisconnectedFromServer
; ===============================================================================================================================
Func _Io_Loop(ByRef $socket, $whoAmI = $g__Io_WhoAmI)

	Local $recvd

	;Local $timer = TimerInit()

	Switch $whoAmI

		Case $_IO_SERVER

			; Accept incomming connections
			Local $connectedSocket = TCPAccept($socket)

			If $connectedSocket <> -1 Then _Event(_Io_ServerEvents_ClientConnected, $connectedSocket, $socket)

			; Handle connected sockets
			For $connectedSocket In $g__io_Sockets.keys() ; in keys we have the socket ID, in .items() the properties of the sockets are stored

				; Attempt to fetch data from connected socket
				$recvd = __Io_RecvPackage($connectedSocket)

				; Handle errors
				Switch @error
					Case 1 ; Client is no longer connected
						_Event(_Io_ServerEvents_ClientDisconnected, $connectedSocket, $socket)
						ContinueLoop
					Case 2 ; Client flooding
						_Event(_Io_CommonEvents_Flooded, $connectedSocket)
						ContinueLoop
				EndSwitch

				; Handle rec
				If $recvd Then __Io_HandleRecvdPackage($recvd, $connectedSocket, $socket)

			Next

		Case $_IO_CLIENT

			; Attempt to fetch data from connected socket
			$recvd = __Io_RecvPackage($socket)

			; Handle errors
			Switch @error
				Case 0 ; No error set
					If $recvd Then __Io_HandleRecvdPackage($recvd, $socket, $socket) ; socket two times is correct because the client only has the servers sockets to take into account
				Case 1 ; Not connected to server
					_Event(_Io_ClientEvents_DisconnectedFromServer, $socket, $g__io_conn_ip, $g__io_conn_port)
					; Because our events cannot handle byrefs
				Case 2 ; Flooded
					_Event(_Io_CommonEvents_Flooded, $socket)
			EndSwitch

	EndSwitch

	;ConsoleWrite(TimerDiff($timer) & @LF)

	Return $g__io_isActive
EndFunc   ;==>_Io_Loop

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_Disconnect
; Description ...: Disconnect from a server / Disconnect a client / Stop server
; Syntax ........: _Io_Disconnect([$socket = $g__io_mySocket])
; Parameters ....: $socket              - [optional] a string value. Default is $g__io_mySocket
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: If the identiy is `$_IO_CLIENT ` OR if the identity is `$_IO_SERVER` and the param `$socket` is not provided.  `_Io_Loop` will start to return `False`. If the identity is `$_IO_SERVER` and a connected socket is passed into `$socket`, the server will disconnect that socket
; Related .......:
; Link ..........:
; Example .......: No
; Events ........: _Io_ServerEvents_ClientDisconnected, _Io_CommonEvents_Disconnected
; ===============================================================================================================================
Func _Io_Disconnect($socket = $g__io_mySocket)
	If $g__Io_WhoAmI == $_IO_SERVER And @NumParams == 1 Then

		If TCPCloseSocket($socket) Then
			_Event(_Io_ServerEvents_ClientDisconnected, $socket)
			Return True
		EndIf

		Return False

	EndIf

	; The client shut down its services
	_Event(_Io_CommonEvents_Disconnected, $socket);

	Return True
EndFunc   ;==>_Io_Disconnect

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_FuncGetArgs
; Description ...: This is the closest thing i can think of to emulate php's "func_get_args", To understand this code, please look in Features\_Io_Emit.au3
; Syntax ........: _Io_FuncGetArgs(Byref $aParams[, $nParamsToUse = 0])
; Parameters ....: $aParams             - [in/out] an array of unknowns.
;                  $nParamsToUse        - [optional] a general number value. Default is 0.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; Events ........: None
; ===============================================================================================================================
Func _Io_FuncGetArgs(ByRef $aParams, Const $nParamsToUse = 0)

	; Slice given params
	If $nParamsToUse > 0 Then

		; If the first value passed is an CallArgArray we replace the wolhe aParams
		If $nParamsToUse == 1 Then

			Const $p1 = $aParams[0]

			If IsArray($p1) And $p1[0] == 'CallArgArray'  Then
				$aParams = $p1
				Return
			EndIf

		EndIf

		; Slice accordinly
		Local $_tmp[$nParamsToUse]

		For $i = 0 To $nParamsToUse - 1
			$_tmp[$i] = $aParams[$i]
		Next

		$aParams = $_tmp

	Else
		$aParams = 0; cus 0 is smaller than Null to send, aslong as its not an array, its ok
	EndIf

EndFunc   ;==>_Io_PrepDynamicParams

#Region Io package handler

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_PrepPackage
; Description ...: Returns a prepared package to be sent with _Io_SendPackage
; Syntax ........: _Io_PrepPackage(Const $sEventName, Const $aData)
; Parameters ....: $sEventName          - [const] a string value.
;                  $aData               - [const] an array of unknowns.
; Return values .: "Socket-Io-package"
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......: _Io_SendPackage
; Link ..........:
; Example .......: No
; Events ........: _Io_CommonEvents_PrepPackage
; ===============================================================================================================================
Func _Io_PrepPackage(Const $sEventName, Const $aData)

	_Event(_Io_CommonEvents_PrepPackage, $sEventName)

	; Create payload of data
	Local Const $packageToSend = [$sEventName, $aData]

	; Serialize and strap ppackage.
	Return _Serialize($packageToSend) & "#"

EndFunc   ;==>_Io_PrepPackage

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_SendPackage
; Description ...: Sends a previously created package to a given socket.
; Syntax ........: _Io_SendPackage(Const $socket, Byref $serialized)
; Parameters ....: $socket              - [const] a string value.
;                  $serialized          - [in/out] a string value.
; Return values .: TcpSend -> BytesSent
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......: _Io_PrepPackage
; Link ..........:
; Example .......: No
; Events ........: _Io_CommonEvents_PackageSent
; ===============================================================================================================================
Func _Io_SendPackage(Const $socket, ByRef $serialized)

	; Check if we should encrypt the data
	If $g__io_vCryptKey Then
		$serialized =  _Crypt_EncryptData($serialized, $g__io_vCryptKey, $g__io_vCryptAlgId)
	EndIf

	Local Const $bytesSent = TCPSend($socket, $serialized)

	_Event(_Io_CommonEvents_PackageSent, $socket, $bytesSent, @error)

	; Send package
	Return $bytesSent
EndFunc   ;==>_Io_SendPackage

#EndRegion Io package handler

; #FUNCTION# ====================================================================================================================
; Name ..........: _Io_FireIoEvent
; Description ...: The UDFS internal event observers. Fire events to previously registred events (`_Io_on('evtName', cb)`)
; Syntax ........: _Io_FireIoEvent(Const $eventName, $eventData, Const Byref $socket, Const Byref $mySocket)
; Parameters ....: $eventName           - [const] an unknown value.
;                  $eventData           - an unknown value.
;                  $socket              - [in/out and const] a string value.
;                  $mySocket            - [in/out and const] a map.
; Return values .: None
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: This function has nothing to do with `_Event` or its functions.
; Related .......:
; Link ..........:
; Example .......: No
; Events ........: _Io_CommonEvents_FireEventAttempt, _Io_CommonEvents_EventNotFired, _Io_CommonEvents_EventFired
; ===============================================================================================================================
Func _Io_FireIoEvent(Const $eventName, $eventData, Const ByRef $socket, Const ByRef $mySocket)

	_Event(_Io_CommonEvents_FireEventAttempt, $eventName, $eventData, $socket, $mySocket)

	If $g__io_Events.item($mySocket).exists($eventName) Then

		; $eventData[0] and $eventData[1] has the value 0 on arrival. Now when the event was found. we can occopy them with the desired data.
		If Not IsArray($eventData) Then
			Local $_tmp = ['CallArgArray', $socket]
			$eventData = $_tmp
		Else
			; Transform eventData to utilize "CallArgArray" and pass the first argument as the given socket
			Local Const $eventDataSize = UBound($eventData); [2, 2]
			Local $_tmp[$eventDataSize + 2] ; [2, 2, x, x]
			$_tmp[0] = 'CallArgArray'
			$_tmp[1] = $socket
			For $i = 2 To $eventDataSize + 1
				$_tmp[$i] = $eventData[$i - 2]
			Next

			$eventData = $_tmp
		EndIf

		; Get the event callable name from the given sockets event store
		Local $eventCallable = $g__io_Events.item($mySocket).item($eventName)

		; Invoke the UDF event
		Call($eventCallable, $eventData)

		If @error == 0xDEAD And @extended == 0xBEEF Then
			_Event(_Io_CommonEvents_EventNotFired, $eventName, $eventData, $socket, $mySocket, "0xDEAD_0xBEEF")
		Else
			_Event(_Io_CommonEvents_EventFired, $eventName, $eventData, $socket, $mySocket)
		EndIf

	Else
		_Event(_Io_CommonEvents_EventNotFired, $eventName, $eventData, $socket, $mySocket, "NOT_FOUND")
	EndIf
EndFunc   ;==>_Io_FireIoEvent

#Region Internals

Func __Io_RecvPackage(Const ByRef $socket)
	Local $package = TCPRecv($socket, 1, 1)
	If @error Then Return SetError(1, 0, Null) ; Connection lost
	If $package == "" Then Return Null

	; Store bytes recvd
	Local $bytesRecvd

	; Fetch all data from the buffer
	Do
		Local $TCPRecv = TCPRecv($socket, $g__io_nPacketSize, 1)
		$package &= $TCPRecv
		$bytesRecvd = BinaryLen($package)

		If $bytesRecvd >= $g__io_nMaxPacketSize Then Return SetError(2, 0, Null)
	Until $TCPRecv == ""

	_Event(_Io_CommonEvents_PackageRecvd, $bytesRecvd)

	$package = BinaryToString($package)

	; Check if we want to decrypt our data
	If $g__io_vCryptKey Then
		$package = _Crypt_DecryptData($package, $g__io_vCryptKey, $g__io_vCryptAlgId)
	EndIf

	Return $package
EndFunc   ;==>__Io_RecvPackage

Func __Io_HandleRecvdPackage(ByRef $sPackage, Const $socket, Const $mySocket)
	; Remove last strap of package load (Can be 1 to n)
	$sPackage = StringRegExpReplace($sPackage, "(?s)(.*)\#$", "$1")

	; create an array of all packages
	Local Const $aPackages = StringSplit($sPackage, "#")

	; Handle all packets
	For $i = 1 To $aPackages[0]
		; append unserialized package product
		Local $eventPayload = _UnSerialize($aPackages[$i])
		Local $eventName = $eventPayload[0]
		Local $eventData = $eventPayload[1]

		_Io_FireIoEvent($eventName, $eventData, $socket, $mySocket)
	Next
EndFunc   ;==>__Io_HandleRecvdPackage

Func __Io_Init()
	Static $firstBootCompleted

	If StringRegExp(@AutoItVersion, "^3.3.1\d+\.\d+$") Then
		If Not @Compiled Then
			If Not $firstBootCompleted Then
				ConsoleWrite("-" & @TAB & "SocketIO.au3: Because you are using Autoit version " & @AutoItVersion & " Opt('TCPTimeout') has been set to 5. You could manually use another value by putting Opt('TCPTimeout', 5) (once) after _Io_Connect or _Io_listen. Why this is done you could read more about here: https://www.autoitscript.com/trac/autoit/ticket/3575" & @LF)
			EndIf
		EndIf
		Opt('TCPTimeout', 5)
	EndIf

	If Not $firstBootCompleted Then
		; Det default on first boot
		_Io_SetOnPrefix()
		_Io_SetRecvPackageSize()
		_Io_SetMaxRecvPackageSize()
		$g__io_Events = ObjCreate("Scripting.Dictionary")
	EndIf

	$firstBootCompleted = True

	Return TCPStartup()
EndFunc   ;==>__Io_Init

#EndRegion Internals
