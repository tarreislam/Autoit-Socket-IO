#include "ServerAndClientEvents.au3"
; Attempt to listen on port 1000
Global $socket = _Io_connect(@IPAddress1, 1000)
If Not $socket Then
	MsgBox(64, "Failed to connect to server", "Failed to connect to server, is the server running?")
	Exit
EndIf

MainLoop()