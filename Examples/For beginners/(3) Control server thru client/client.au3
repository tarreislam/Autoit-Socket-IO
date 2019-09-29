; Include SocketIO
#include "..\..\..\socketIO.au3"
; Include autoit udfs
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

; Start the server on port 1000
Global $socket = _Io_Connect(@IPAddress1, 1000)

; Include all events
#include "serverAndClientEvents.au3"

; Make sure we are compiled
If Not @Compiled Then
	Exit MsgBox(64, "", "Please compile before running. Tools -> Build")
EndIf

If @error Then
	ConsoleWrite("Failed to connect to port 1000" & @LF)
Else
	ConsoleWrite("Successfully connected to port 1000" & @LF)
EndIf

; Create the server GUI
Opt('GUIOnEventMode', 1); We want to use GuiCtrlSetOnEvent instead of the loop
Global $hGUI = GUICreate("CLIENT GUI", 266, 123, Random(10, 500, 1))
GUICtrlCreateLabel("Name", 8, 8, 32, 17)
Global $inputName = GUICtrlCreateInput("", 8, 32, 249, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_CENTER))
GUICtrlCreateLabel("Address", 8, 64, 36, 17)
Global $inputAddress = GUICtrlCreateInput("", 8, 88, 249, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_CENTER))
GUISetState()

GUISetOnEvent($GUI_EVENT_CLOSE, _EXIT)
GUICtrlSetOnEvent($inputName, inputChanged)
GUICtrlSetOnEvent($inputAddress, inputChanged)

; Main loop
While _Io_Loop($socket)
WEnd


Func inputChanged()
	Local $newName = GUICtrlRead($inputName)
	Local $newAddress = GUICtrlRead($inputAddress)
	; As a client we cannot use Broadcast since its a server-side only feature. As a client we can just Emit data.
	_Io_Emit($socket, 'changeInput', $newName, $newAddress)
EndFunc

Func _EXIT()
	Exit
EndFunc