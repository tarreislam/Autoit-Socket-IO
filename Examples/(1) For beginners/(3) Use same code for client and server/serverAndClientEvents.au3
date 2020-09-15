#include-once
;
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
; Include IO core + the features we want to use for the server
#include "..\..\..\socketIO-Core.au3"
#include "..\..\..\Features\_Io_Emit.au3"
#include "..\..\..\Features\_Io_Broadcast.au3"
#include "..\..\..\Features\_Io_Debug.au3"

Func MainLoop()
	#forcedef $socket
	; Register events
	registerEvents()
	; Start gui
	StartGui()
	; Main loop
	While _Io_Loop($socket)
	WEnd
EndFunc

Func RegisterEvents()
	_Io_On('connection'); _On_connection
	_Io_On('disconnect'); _On_disconnect
	_Io_On('changeInput'); _On_newFancyNumber
EndFunc

#Region Io events
; This event is only fired on the server
Func _On_connection(Const $socket)
	#forcedef $inputName, $inputAddress
	ConsoleWrite("Someone connected" & @LF)

	; Since a new client joined. We have to send him the data all the other nodes have
	_Io_Emit($socket, 'changeInput', GUICtrlRead($inputName), GUICtrlRead($inputAddress))

EndFunc

; This event is fired on both the server and the client
Func _On_disconnect(Const $socket)
	#forcedef $hGUI

	If _Io_IsServer() Then
		ConsoleWrite("Someone disconnected" & @LF)
	EndIf

	If _Io_IsClient() Then
		MsgBox(64, "", "Not connected to server. Exiting", 0, $hGUI)
		Exit
	EndIf
EndFunc

; This event is fired on both the server and the client
Func _On_changeInput(Const $socket, $name, $address)
	#forcedef $inputName, $inputAddress
	GUICtrlSetData($inputName, $name)
	GUICtrlSetData($inputAddress, $address)

	; Since we are sharing events with client and server. We can make an easy check to run server-only events
	If _Io_IsServer() Then
		_Io_Broadcast($socket, 'changeInput', $name, $address)
	EndIf
EndFunc
#EndRegion

#Region other
Func StartGui()
	;_Io_DevDebug(); Uncomment to attach deubber
	; Create the server GUI
	Opt('GUIOnEventMode', 1); We want to use GuiCtrlSetOnEvent instead of the loop
	Global $hGUI = GUICreate(_Io_whoAmI(True), 266, 123, Random(10, 500, 1))
	GUICtrlCreateLabel("Name", 8, 8, 32, 17)
	Global $inputName = GUICtrlCreateInput("", 8, 32, 249, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_CENTER))
	GUICtrlCreateLabel("Address", 8, 64, 36, 17)
	Global $inputAddress = GUICtrlCreateInput("", 8, 88, 249, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_CENTER))
	GUISetState()

	GUISetOnEvent($GUI_EVENT_CLOSE, _EXIT)
	GUICtrlSetOnEvent($inputName, inputChanged)
	GUICtrlSetOnEvent($inputAddress, inputChanged)

EndFunc

Func inputChanged()
	#forcedef $socket
	Local $newName = GUICtrlRead($inputName)
	Local $newAddress = GUICtrlRead($inputAddress)


	If _Io_IsServer() Then
		_Io_BroadCastToAll($socket, 'changeInput', $newName, $newAddress)
	EndIf

	If _Io_IsClient() Then
		_Io_Emit($socket, 'changeInput', $newName, $newAddress)
	EndIf

EndFunc

Func _EXIT()
	Exit
EndFunc

#EndRegion