# Documentation / Understanding how sockets are stored

[Go back to Documentation](README.md)

## Introduction

Connected sockets are now stored in something that is called a [Scripting Dictionary](https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/dictionary-object) that allows us to have key-item pairs instead of 0-based arrays. This is pretty neat because for loops becomes a things in the past when searching



### How to work with _Io_getSockets()

Here are some examples on how you can work with the _Io_getSockets method

```
$sockets = _Io_getSockets()

$numSockets = sockets.count(); Will return how many sockets are connected

; Looping thru all sockets
for $socket in _Io_getSockets()
	local $socketProp = sockets.item($socket)
	local $ipAddress = $socketProp.item("ip"); The IP address of the connected socket
	local $connectedAt = $socketProp.item("connected_at"); YYYY-MM-DD HH:MM:SS 
	
	MsgBox(64, "Socket " & $socket, "IP = " & $ipAddress & @LF & "Connected at = " & $connectedAt)
next

; Checking if a socket exists
if $sockets.exists(1234) Then 
	MsgBox(64, "", "Socket exists")
Else
	MsgBox(64, "", "Socket does not exist")
EndIf

; Getting data from a specified socket
msgBox(64, "Ip from socket 1234", $sockets.item(1234).item("ip"))

; Adding custom props to sockets
$sockets.item(1234).add("customKey", 1337)

; Removing custom props
$sockets.item(1234).remove("customKey")


```







