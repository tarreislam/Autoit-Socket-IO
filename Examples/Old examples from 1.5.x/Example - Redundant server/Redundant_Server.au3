#AutoIt3Wrapper_Change2CUI=Y
#include "..\..\..\socketIO.au3"
#include <Array.au3>

If Not @Compiled Then
	MsgBox(0, "", "Compile this file, then run the .bat file in the same directory")
	Exit
EndIf

; This example uses 2 different roles
; 1 - Master
; 2 - Slave

; ~ Load local configuration
Global $__config_default_listen_port = $CmdLine[1]
Global $__config_master_listen_port = IniRead($__config_default_listen_port & ".ini", "config", "master", Null)
Global $__config_role = IniRead($__config_default_listen_port & ".ini", "config", "role", Null)
Global $__config_slaves = StringSplit(IniRead($__config_default_listen_port & ".ini", "config", "slaves", Null), ",")

; ~ This is the data we want to keep up, even if an unexpected server crash occured
Global $__important_data = 0, $__initial_connect_as_slave


; ~ misc variables
Global $__server, $__client


; Start a server with our default port
$__server = _IO_Listen($__config_default_listen_port)
If @error Then
	MsgBox(0, "Failed to listen", @error)
	Exit
EndIf
ConsoleWrite("Listening on port: " & $__config_default_listen_port & @LF)

; IF our role is slave, we connect to the master port and
If $__config_role == "slave" Then

	; Wait for master to respond
	Do
		$__client = _Io_Connect(@IPAddress1, $__config_master_listen_port, False); Autoreconnect is disabled because we do not want ot reconnect to a dead master.
	Until Not @error

	$__initial_connect_as_slave = True

EndIf

; Bind server events
_Io_On('connection', _Callback_Server_OnConnection, $__server)

; Bind client events
_Io_On('important data', _Callback_Slave_ImportantData, $__client)
_Io_On('disconnect', _Callback_Slave_DisconnectedFromMaster, $__client)


Global $__timer = TimerInit()
Global $__lastRole
while 1

	If $__lastRole <> $__config_role Then
		ConsoleWrite("New role: " & $__config_role & @LF)
		$__lastRole = $__config_role
	EndIf

	If $__config_role == "master" Then
		_Io_Loop($__server, $_IO_LOOP_SERVER)

		If TimerDiff($__timer) > 1000 Then

			; modify the important data
			$__important_data += 1
			$__timer = TimerInit()

			ConsoleWrite("Sending important data to slaves. Current value: " & $__important_data & @LF)

			; Send important data to all slaves
			_Io_BroadCastToall($__server, 'important data', $__important_data, $__config_slaves)

		EndIf


	ElseIf $__config_role == "slave" Then
		; As a slave, we only listen for events.
		_Io_Loop($__client, $_IO_LOOP_CLIENT)
	EndIf


WEnd


Func _Callback_Server_OnConnection(ByRef $socket)
	ConsoleWrite("A node has connected to the server." & @LF)
EndFunc

Func _Callback_Slave_ImportantData(ByRef $socket, $important_data, $slaves)
	ConsoleWrite("Important data received from master: " & $important_data & @LF)

	; Update the slave
	$__important_data = $important_data
	$__config_slaves = $slaves

EndFunc

Func _Callback_Slave_DisconnectedFromMaster(ByRef $socket)

	; This is used here to prevent the initial connect from trying to connect to another master.
	If Not $__initial_connect_as_slave Then Return False

	; If the master is dead, we calculate the next server to use as master
	; If we are the next port in the stack, we promote ourself
	If $__config_slaves[1] == $__config_default_listen_port Then

		; Change role to master
		$__config_role = "master"

		; Remove self from array
		_ArrayDelete($__config_slaves, 1)
		$__config_slaves[0] -=1
	Else


		; No more to connect to
		If $__config_slaves[0] == 0 Then
			$__config_role = "master"
			Return
		EndIf

		; If we are not the current master, we connect to the new master
		Local $new_client = _Io_Connect(@IPAddress1, $__config_slaves[1], False)
		; If we could not connect to the next host, we promot ourself
		If @error Then
			; Remove first elm if we could not connect
			_ArrayDelete($__config_slaves, 1)
			$__config_slaves[0] -=1
			Return
		Else
			ConsoleWrite("Connected to " & $__config_slaves[1] & @LF)
		EndIf

		; Change ot our new client socket.
		_Io_TransferSocket($__client, $new_client)


	EndIf

EndFunc

