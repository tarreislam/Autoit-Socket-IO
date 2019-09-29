; Include SocketIO
#include "..\..\..\socketIO.au3"
; Include autoit udfs
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

; Start the server on port 1000
Global $socket = _Io_listen(1000)

; Register all events
#include "serverAndClientEvents.au3"

; Make sure we are compiled
If Not @Compiled Then
	Exit MsgBox(64, "", "Please compile before running. Tools -> Build")
EndIf

If @error Then
	ConsoleWrite("Failed to listen on port 1000" & @LF)
Else
	ConsoleWrite("Listening on port 1000 and waiting for client" & @LF)
EndIf

; Create the server GUI
Opt('GUIOnEventMode', 1); We want to use GuiCtrlSetOnEvent instead of the loop
Global $hGUI = GUICreate("Server GUI", 266, 123, 298, 312)
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
	; As a server. We cannot use _Io_emit in the global scope, inside an already accepted event, we can use emit to only talk to a specified client
	; But here we have to broadcast these changes, and the client has the reversed rule.
	_Io_BroadCastToAll($socket, 'changeInput', $newName, $newAddress)
EndFunc

Func _EXIT()
	Exit
EndFunc