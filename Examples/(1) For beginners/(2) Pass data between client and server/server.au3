; Make this an console application
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Run_After=start cmd /c server.exe
; Include IO core + the features we want to use for the server
#include "..\..\..\socketIO-Core.au3"
#include "..\..\..\Features\_Io_Emit.au3"
#include "..\..\..\Features\_Io_Debug.au3"

; Define some resources
Global $userList = ObjCreate("Scripting.Dictionary")

; Attempt to listen on port 1000
Global $socket = _Io_listen(1000)

If Not $socket Then
	MsgBox(64, "Failed to start server", "Failed to listen on port 1000. Is it already listening?")
	Exit
EndIf

;_Io_DevDebug() ; Uncomment to attach deubber

; Bind events
_Io_On('connection'); _On_connection
_Io_On('data_from_client'); _On_ping


; Main loop
While _Io_Loop($socket)
WEnd


#Region Io events

Func _On_connection(Const $socket)
	; Here we will send the event "dataRequest" to our client.
	_Io_Emit($socket, 'dataRequest')
EndFunc

Func _On_Data_from_client(Const $socket, $dataSentFromClient)
	; Print request
	_Io_DevDebug_Info("$dataSentFromClient = " & $dataSentFromClient)
	; Ask for more data!
	_Io_Emit($socket, 'dataRequest')
EndFunc

#EndRegion