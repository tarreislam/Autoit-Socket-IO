# SocketIo for AutoIt

Yep yep, this is pretty much an attempt to port the existing project [https://socket.io/](https://socket.io/) to AutoIt's Codebase. So i will not go in to so much detail.

 
* This is how the communication is done http://i.imgur.com/0mMfsBD.png
* Each client is isolated to the server http://i.imgur.com/rVO2LFb.png


### Features
* Easy API 
* VarType Translation (Example: If the server sends an int, the client will receive an int and vice versa)
* Two solid examples (1 Basic, 1 Advanced)

### Limitations / Drawbacks
* Every Broadcast/Emit is limited to a maximum of 10 parameters
* Every Callback Function has to have the same number of parameters as the Broadcasted/Emited event
* It is not possible to Broadcast/Emit an array as a parameter (**This will probably be supported soon**)
* Rooms and namespaces are not supported yet (**This will probably be supported soon**)


#### Server methods
* `_Io_Listen($iPort, $iAddress = @IPAddress1, $iMaxPendingConnections = Default, $iMaxDeadSocketsBeforeTidy = 1000)`

> Returns a TCP socket

* `_Io_Broadcast(ByRef $socket, $sEventName, $p1, $p2, ...$p10)`

> Emits an event to all connected sockets besides $socket
> Does not return anything

* `_Io_BroadcastToAll(ByRef $socket, $sEventName, $p1, $p2, ...$p10)`

> Emits an event to all connected sockets
> Does not return anything

* `_Io_socketGetProperty(ByRef $socket, $sProp = Default)`

> Retrieves information about the socket. Default = Array of all properties.
> Available properties: "ip", "date", "room"

* `_Io_getSocketsCount()`

> Returns the total amount of sockets regardles of state

* `_Io_getDeadSocketCount()`

> Returns the total amount of sockets regardles of state

#### Client methods
* `_Io_Connect($iAddress, $iPort, $bAutoReconnect = False)`

> Returns a TCP socket

* `_Io_Reconnect(ByRef $socket)`

 > Attempts to reconnect.
 > Returns a TCP socket

#### Server and Client methods
* `_Io_getVer()`

Returns the current version

* `_Io_Emit(ByRef $socket, $sEventName, $p1, $p2, ...$p10)`

> Emits an event to the given socket.
> Does not return anything

* `_Io_Loop(ByRef $socket)`

> Used to recive and parse events.
> Should only be used as the main While loop

* `_Io_LoopFacade()`
> Should only be used with AdlibRegister
