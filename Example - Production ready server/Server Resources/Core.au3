#include-once
#include "Program.au3"
#include "Network\Events.au3"


; Server maintenence and log resources. Please do not edit.
Global $__iNetworkTicks = 0, $__LogHandle

Func Server_getNetworkTicks()
	return $__iNetworkTicks
EndFunc

Func Server_resetNetworkTicks()
	$__iNetworkTicks = 1
EndFunc

Func Server_getServerTickAdvantage(ByRef $delta); Returns how many time the server is ahead of the given number

	; Reset delta if needed. This will only occur if __iNetworkTicks is 0
	If ($delta / $__iNetworkTicks > 1) Then $delta = 1

	Return $__iNetworkTicks / $delta
EndFunc

Func Server_reachServerTickAdvantage(ByRef $delta)
	$delta = $__iNetworkTicks
EndFunc

Func _Log($suffix, $message)
	Local $now = StringFormat('%s-%s-%s %s:%s:%s', @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)
	Local $row = $suffix & ' [' & $now & ']: ' & $message
	FileWriteLine($__LogHandle, $row)
	If $__LogLevel == 'verbose' Then ConsoleWrite($row & @LF)
EndFunc

Func _Log_Init()
	If $__LogHandle Then FileClose($__LogHandle)
	$__LogHandle = FileOpen($__DefaultLogFileName, 1)

	If $__LogHandle == -1  Then
		_Log('!', StringFormat('Failed to open file "%s" for $FO_APPEND. Error: %d. See more at https://www.autoitscript.com/autoit3/docs/functions/FileOpen.htm', $__DefaultLogFileName, @error))
		Return SetError(@error)
	EndIf

EndFunc


;	/*
;	|--------------------------------------------------------------------------
;	| Core internarls
;	| ----------------
;	| These functions are only internally.
;	|--------------------------------------------------------------------------
;	*/

Func __Server_DefaultPreScript(Const $sEventName, Const $sFuncName)
	#forceref $sEventName, $sFuncName
	$__iNetworkTicks += 1
EndFunc

Func __ByeBye()
	Local Const $onExit = 'OnExit'; Trick Scite into calling OnExit even if it does not exist
	_Log('>', 'Shutting down')
	Call($onExit)
EndFunc

Func __Init()
	Local $socket = __BootstrapServer()

	__Network_Events($socket)

	Program($socket)
EndFunc

Func __BootstrapServer()

	; Set settings
	_Io_DevDebug($__debug)
	_Io_setRecvPackageSize($__iRecvPackageSize)
	_Io_SetMaxRecvPackageSize($__iMaxPackageSize)
	_Io_setEventPreScript(__Server_DefaultPreScript)

	; Start services
	_Log_Init()

	; Enable encryption if we need to
	If $__EnableEncryption Then
		_Io_EnableEncryption($__EncryptionKeyOrFile, $__EncryptionAlgorithm)
		If Not @error Then
			_Log('+', StringFormat("Successfully enabled encryption. Key or file: %s. Alghorithm: %s.", $__EncryptionKeyOrFile, $__EncryptionAlgorithm))
		Else
			Switch @error
				Case 1
					_Log('!', StringFormat("Failed enable encryption. Key or file: %s. Does not exist or is invalid", $__EncryptionKeyOrFile))
				Case 2
					_Log('!', StringFormat("Failed enable encryption. Error: %d. See more at https://www.autoitscript.com/autoit3/docs/libfunctions/_Crypt_Startup.htm", @error))
				Case 3
					_Log('!', StringFormat("Failed enable encryption. Error: %d. See more at https://www.autoitscript.com/autoit3/docs/libfunctions/_Crypt_EncryptData.htm", @error))
				Case 4
					_Log('!', StringFormat("Failed enable encryption. Error: %d. See more at https://www.autoitscript.com/autoit3/docs/libfunctions/_Crypt_DecryptData.htm", @error))
				Case 5
					_Log('!', StringFormat("Failed enable encryption. Error: %d. The Decrypted data and the test string does not match. It may be a bug?", @error))
			EndSwitch

			Exit(9 + @extended)
		EndIf
	EndIf

	; Attempt to start listen for connections.
	Local $socket = _Io_Listen($__iDefaultPort, $__sDefaultIp, $__iMaxDeadSocketsBeforeTidy, $__iMaxConnections)

	If Not @error Then
		_Log('+', StringFormat("Accepting connections on %s:%d.", $__sDefaultIp, $__iDefaultPort))
		OnAutoItExitRegister('__ByeBye')
		Return $socket
	Else
		Switch @error
			Case 1
				_Log('!', "Failed to startup the TCP protocol. See more at https://www.autoitscript.com/autoit3/docs/functions/TCPStartup.htm")
				Exit(20)
			Case 2
				Switch @extended
					Case 1
						_Log('!', StringFormat("Failed to listen on %s:%d. Error %d. The ip address '%s' is invalid. See more at https://www.autoitscript.com/autoit3/docs/functions/TCPListen.htm", $__sDefaultIp, $__iDefaultPort, $__sDefaultIp, @error))
					Case 2
						_Log('!', StringFormat("Failed to listen on %s:%d. Error %d. The port '%s' address is invalid. See more at https://www.autoitscript.com/autoit3/docs/functions/TCPListen.htm", $__sDefaultIp, $__iDefaultPort, $__iDefaultPort, @error))
					Case Else
						_Log('!', StringFormat("Failed to listen on %s:%d. Error %d. General error. See more at https://www.autoitscript.com/autoit3/docs/functions/TCPListen.htm", $__sDefaultIp, $__iDefaultPort, @error))
				EndSwitch
				Exit(20 + @extended)
		EndSwitch

	EndIf

EndFunc