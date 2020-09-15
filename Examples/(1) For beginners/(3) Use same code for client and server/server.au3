#include "ServerAndClientEvents.au3"
; Attempt to listen on port 1000
Global $socket = _Io_listen(1000)
If Not $socket Then
	MsgBox(64, "Failed to start server", "Failed to listen on port 1000. Is it already listening?")
	Exit
EndIf

MainLoop()