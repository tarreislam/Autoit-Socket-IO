; Make this an console application
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Run_After=start cmd /c client.exe
; Include IO core + the features we want to use for the client
#include "..\..\..\socketIO-Core.au3"
#include "..\..\..\Features\_Io_Emit.au3"
#include "..\..\..\Features\_Io_Debug.au3"

; Connect to server
Global $socket = _Io_connect(@IPAddress1, 1000)
If Not $socket Then
	MsgBox(64, "Failed to connect to server", "Failed to connect to server, is the server running?")
	Exit
EndIf

;_Io_DevDebug(); Uncomment to attach deubber

; bind events
_Io_On('dataRequest')

; Main loop
While _Io_Loop($socket)
WEnd


#Region Io events
Func _On_dataRequest(Const $socket)

	Local Const $data = InputBox("The server has requested some data", "enter anything")
	If @error Then _Io_Disconnect()

	_Io_Emit($socket, 'data_from_client', $data)
EndFunc
#EndRegion