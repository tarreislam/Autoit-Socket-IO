#include "..\socketIO.au3"

If Not @Compiled Then
	MsgBox(0, "", "You should compile me")
	;Exit
EndIf

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Global $username = InputBox("Enter username", "", @UserName & Random(100,1000,1))

; Its recommended to always use Gui events to remove the programs main focus from updating the GUI
Opt("GUIOnEventMode", 1)

#Region ### START Koda GUI section ### Form=
Global $hGUI = GUICreate("Example chat - " & $username, 492, 320, 258, 249)
Global $hUserList = GUICtrlCreateList("", 8, 32, 121, 279)
GUICtrlCreateLabel("Users", 8, 8, 31, 17)
GUICtrlCreateLabel("Chat", 136, 8, 31, 17)
Global $hInput = GUICtrlCreateInput("", 136, 288, 265, 21)
Global $hSend = GUICtrlCreateButton("Send", 408, 288, 75, 25)
Global $hChat = GUICtrlCreateEdit("", 136, 32, 345, 249, BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_READONLY,$ES_WANTRETURN,$WS_VSCROLL))
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

; Connect to server
Global $_socket = _Io_Connect(@IPAddress1, 1337, True)
If @error Then
	MsgBox(0, "Failed to connect", @error)
	Exit
EndIf

; Register io events
_Io_on("disconnect", LostConnection)
_Io_on("message", Message)
_Io_on("joined", UserJoined)
_Io_on("userlist", UpdateUserList)

; Register gui events
GUICtrlSetOnEvent($hSend, "SendMessage")
GUISetOnEvent($GUI_EVENT_CLOSE, "_quit")

; Notify server that we are here!
_Io_Emit($_socket, "join", $username)

; Request the userlist
_Io_Emit($_socket, "request", "userlist")

; Start the main loop
While _Io_Loop($_socket)
WEnd

; Io event Callbacks
Func Message(ByRef $socket, $name, $message)
	Local $finished_message = StringFormat("%s: %s", $name, $message)
	AppendMessage($finished_message)
EndFunc


Func LostConnection(ByRef $socket)
	GUICtrlSetState($hInput, $GUI_DISABLE)
	AppendMessage("Lost connection to chat :( :( :(")
	MsgBox(0,0, "Lost connection. Press OK to reconnect")
	GUICtrlSetState($hInput, $GUI_ENABLE)
EndFunc


Func UserJoined(ByRef $socket, $name)
	Local $finished_message = StringFormat("%s has joined the chat!", $name)
	GUICtrlSetData($hChat, GUICtrlRead($hChat)  & $finished_message & @CRLF)
	; Re-request the userlist
	_Io_Emit($_socket, "request", "userlist")
EndFunc

Func UpdateUserList(ByRef $socket, $user_names)
	; Strip last |
	$user_names = StringSplit(StringRegExpReplace($user_names, "(.*)\|", "$1"), "|")
	GUICtrlSetData($hUserList, "")
	For $i = 1 To $user_names[0]
		GUICtrlSetData($hUserList, $user_names[$i])
	Next
EndFunc

; Gui functions
Func SendMessage()
	; Send message
	_Io_Emit($_socket, "message", $username, GUICtrlRead($hInput))
	; Clear input
	GUICtrlSetData($hInput, "")
EndFunc

Func AppendMessage($msg)
	GUICtrlSetData($hChat, GUICtrlRead($hChat)  & $msg & @CRLF)
EndFunc


Func _quit()
	Exit
EndFunc
