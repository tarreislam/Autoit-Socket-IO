# AutoIt-SocketIo

Yep yep, this is pretty much an attempt to port the existing project's concept [https://socket.io/](https://socket.io/) to AutoIt's Codebase. So i will not go in to so much detail.


* This is how the communication is done http://i.imgur.com/0mMfsBD.png
* Each client is isolated to the server http://i.imgur.com/rVO2LFb.png


### Features
* Easy API
* VarType Translation (Example: If the server sends an int, the client will receive an int and vice versa)
* Fully featured examples
* Data encryption (Using Autoit's UDF Crypt.au3)

### Limitations / Drawbacks
* Every Broadcast/Emit is limited to a maximum of 16 parameters
* Every Callback Function has to have the same number of parameters as the Broadcasted/Emited event
* It is not possible to Broadcast/Emit objects
* Only 1D-arrays are allowed to be Broadcasted/Emitted (**2D arrays will probably never be supported**)


### Changelog

**Version 1.2.0** (This update **DOES NOT** break scripts)
 * Added an option to set the packet-size of TCP-transports, see `_Io_setRecvPackageSize`
 * Got rid of unnecessary StringLen's in `_Io_loop`
 * Changed `__Io_TidyUp` to `_Io_TidyUp` and added it to the public Api reference list.
 * Changed `$iMaxDeadSocketsBeforeTidy` default value from `1000` to `100` and added an option to disable it, read more at `_Io_Listen`
 * Changed `$bAutoReconnect` from `False` to `True`.
 * Fixed gitignore epicZ fail
 * Improvemend Documentation

**Version 1.1.0** (This update **DOES NOT** break scripts)
 * Fixed bug when Emitting / Broadcasting without any parameters causing a $fCallback crash
 * Optimized Package-handling once again.
 * Added 1D-Array support (Endless nestning).
 * Added Subscriptions (See `_Io_Subscribe` `_Io_Unsubscribe` and `_Io_BroadcastToRoom`).
 * Added new example for subscriptions (Be sure to use different room names when joining with clients)
 * Added Unit testing (See `Tests\Runner.au3` and `Tests\Tests.au3`, to run tests you need a udf found here: [https://github.com/tarreislam/Autoit-Unit-Tester](https://github.com/tarreislam/Autoit-Unit-Tester))

**Version 1.0.0**
 * (This update **DOES NOT** break scripts)
 * Added data encryption (Using Autoit's UDF Crypt.au3) See more at `_Io_EnableEncryption`
 * Added new method `_Io_Disconnect` which can be used with both servers and clients
 * Improved package-handling to increase performance
 * Increased the limit of Broadcasted/Emit parameters from 10 to 16


## Api methods

#### Server methods
* `_Io_Listen($iPort, $iAddress = @IPAddress1, $iMaxPendingConnections = Default, $iMaxDeadSocketsBeforeTidy = 100)`

> Listens for incomming connections.
> Returns a SocketID.
> If `$iMaxDeadSocketsBeforeTidy` is set to False, you have to manually invoke `_Io_TidyUp` to get rid of dead sockets.

* `_Io_Subscribe(ByRef $socket, $sRoomName)`

> Subscribes socket to a room.
> Returns nothing.
> To emit to these subscriptions see `_Io_BroadcastToRoom`.

* `_Io_Unsubscribe(ByRef $socket, $sRoomName = null)`

> Unsubscribes a socket from a room.
> Returns nothing.
> If $sRoomName is null, every subscription will expire

* `_Io_Broadcast(ByRef $socket, $sEventName, $p1, $p2, ...$p16)`

> Emits an event to all connected sockets besides the originator.
> Returns nothing.
> -

* `_Io_BroadcastToAll(ByRef $socket, $sEventName, $p1, $p2, ...$p16)`

> Emits an event to all connected sockets.
> Returns nothing.
> $socket is ignored in this function

* `_Io_BroadcastToRoom(ByRef $socket, $sDesiredRoomName, $sEventName, $p1, $p2, ...$p16)`

> Emits an event to all connected sockets in the given room name.
> Returns nothing.
> See more at `_Io_Subscribe`

* `_Io_socketGetProperty(ByRef $socket, $sProp = Default)`

> Retrieves information about the socket.
> Returns Array || String.
> Default = Array of all properties. Available properties: "ip", "date".

* `_Io_getDeadSocketCount()`

> -.
> Returns the number of all dead sockets
> -.

* `_Io_getSocketsCount()`

> -.
> Returns the number of all sockets (Regardless of state)
> -.


* `_Io_TidyUp()`

> Re-builds array of active sockets.
> Returns nothing.
> Only use this function if `$iMaxDeadSocketsBeforeTidy` i set to `False`

#### Client methods
* `_Io_Connect($iAddress, $iPort, $bAutoReconnect = True)`

> Attempts to connect to a Server
> Returns a SocketID.
> if `$bAutoReconnect` is set to `False`. You must use `_Io_Connect` or `_Io_Reconnect` to establish a new connection

* `_Io_Reconnect(ByRef $socket)`

> Attempts to reconnect to the server
> Returns a SocketID.
> This function is invoked automatically if `$bAutoReconnect` is set to `True`.

#### Server and Client methods
* `_Io_getVer()`

> -.
> Returns the current (semantic version)[http://semver.org/] of the UDF
> -.

* `_Io_On(Const $sEventName, Const $fCallback)`

> Binds an event.
> Returns nothing.
> `$fCallback` has to be an actual function reference, no strings!

* `_Io_Emit(ByRef $socket, $sEventName, $p1, $p2, ...$p16)`

> Emits an event to the given socket.
> Returns nothing.
> Only `1D-Arrays, Ints, Floats, Doubles, Ptrs, Binarys, Strings, Null-keywords or Bools` should be used as parameters.

* `_Io_Loop(ByRef $socket)`

> The event engine.
> Returns a bool.
> Should only be used as the main While loop. The function will return false if the function `_Io_Disconnect` is invoked

* `_Io_LoopFacade()`

> A substitute for the `_Io_Loop` solution
> Returns nothing.
> Should only be used with AdlibRegister. If `_Io_Disconnect` is invoked, this facade will also be un-registered. This function will not work properly if more than 1 `_Io_Connect` or `_Io_Listen` exists in the same script.

* `_Io_EnableEncryption($sFileOrKey, $CryptAlgId = $CALG_AES_256)`

> Encrypts data between the server and the client with the use of Autoit's Crypt.au3.
> Returns true if successfully configured, else @error is set.
> The encryption has to be enabled on both sides for it to work.


* `_Io_Disconnect()`

> Manually disconnect the connection
> Returns nothing.
> This function will purge any previously set `_Io_LoopFacade` and cause `_Io_Loop` to return false.

* `_Io_setRecvPackageSize($nPackageSize = 2048)`

> Sets the maxlen for [TCPRecv](https://www.autoitscript.com/autoit3/docs/functions/TCPRecv.htm)
> Returns nothing.
> Is set default to 2048 by both the server and the client.

## Default events

#### Server events
* `connection`

> Takes 1 parameter ($socket)

#### Server and Client events
* `disconnect`

> Takes 1 parameter ($socket)