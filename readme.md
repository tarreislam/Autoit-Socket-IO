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

**Version 1.4.0** (This update **DOES NOT** break scripts)
 * Added a new server method: `_Io_getSockets` which will return an array of all sockets. See more in the doc
 * Added a banning-system, see more at: `_Io_getBanlist`, `_Io_Ban`, `_Io_Sanction`, `_Io_IsBanned`
 * Added a new default event for clients `banned`. See more at default events
 * Added two new `client` and `server` methods `_Io_setEventPreScript` And `_Io_setEventPostScript`. The intent for these is to not DRY when doing debug \ tasks that requires to be ran before or after events.
 * Added a new `client` and `server` method `_Io_ClearEvents`.
 * Added a third optional parameter to `_Io_On` called `$socket`, you may only pass the socket returned from `_Io_Listen` or `_Io_Connect`. The intent for this change is to allow for server + client in the same envoirment.
 * Added a second parameter to `_Io_Loop` called `$WhoAmI` which should used with the new enums `$_IO_SERVER` and `$_IO_CLIENT`. The intent for this change is to allow for server + client in the same envoirment.
 * Added a new `client` method `_Io_TransferSocket`.
 * Added a new `server` method `_Io_getActiveSocketCount`.
 * Optimations, avoiding `Redim`s and unnecessary nested arrays as good as possible etc.

**Version 1.3.0** (This update **DOES NOT** break scripts)
 * Got rid of unnecessary `Redim`s with sockets and subscriptions in the main loop (This increased write performence greatly)
 * Changed `$iMaxDeadSocketsBeforeTidy` from `100` to `1000`
 * Changed `_Io_setRecvPackageSize($nPackageSize = 2048)` to `_Io_setRecvPackageSize($nPackageSize = 4096)` because 2017.
 * Added Tests for both subscriptions and the automatic TidyUp
 * Added a new server method: `_Io_getMaxConnections`
 * Added a new server method: `_Io_getMaxDeadSocketsCount`
 * Added a fifth parameter to the `_Io_Listen` method called `$iMaxConnections` which defaults to `100000`. If the iMaxConnection + 1 user connects, they will be instantly disconnected.
 * Added a parameter to `_Io_Disconnect` called `$socket` which defaults to `null`.  If the `iMaxConnections + 1` client connects, they will be instantly disconnected.


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
* `_Io_Listen($iPort, $iAddress = @IPAddress1, $iMaxPendingConnections = Default, $iMaxDeadSocketsBeforeTidy = 1000, $iMaxConnections = 100000)`

> Listens for incomming connections.
> Returns a SocketID.
> If `$iMaxDeadSocketsBeforeTidy` is set to False, you have to manually invoke `_Io_TidyUp` to get rid of dead sockets. If the `iMaxConnections + 1` client connects, they will be instantly disconnected.

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

* `_Io_getSockets($bForceUpdate = False, $socket = $__g_io_mySocket, $whoAmI = $__g_io_whoami)`

>
> Returns all stored sockets, [$i + 0] = socket, [$i + 1] = ip, [$i + 2] = Date joined (YYYY-MM-DD HH:MM:SS)
> Ubound wont work propery with this array, so use The `$aArr[1]` element to retrive the size. `For $i = 1 to $aArr[1] step +3 ......`. the socket is (Keyowrd) "Null" if the socket is dead.

* `_Io_getDeadSocketCount()`

>
> Returns the number of all dead sockets.
>

* `_Io_getSocketsCount()`


>
> Returns the number of all sockets (Regardless of state).
>

* `_Io_getActiveSocketCount()`

>
> Returns the number of all active connections.
>

* `_Io_getMaxConnections()`


>
> Returns the maximum allowed connections.
>


* `_Io_getMaxDeadSocketsCount()`


>
> Returns the maximum allowed dead connections before `_Io_TidyUp()` is invoked.
>


* `_Io_getBanlist($iEntry = Default)`

> Returns an array of the whole banlist.
> If `$iEntry` is set to any number but `Default` the data for that entry will be retuned instead.


* `_Io_Ban($socketOrIp, $nTime = 3600, $sReason = "Banned", $sIssuedBy = "system")`

> Ip ban and prevent incomming connections from a given socket \ ip.
> Returns True all the time.
> If a `$socket` is passed, the ip will be retrived from the socket and the client will be disconnected, upon reconnecting, the `banned` event will be emitted to the banned client (If they still are banned)


* `_Io_Sanction($socketOrIp)`

> Removes a previous banned ip address.
> Returns `True` if the ban was removed, returns `False` if the ip could not be found.
> If a `$socket` is passed, the ip will be retrived from the socket.

* `_Io_IsBanned($socketOrIp)`

> Checks if an ip exists in the banlist
> Returns the `$index` of the banned ip if found, returns false if not found.
> If a `$socket` is passed, the ip will be retrived from the socket.


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

* `_Io_setEventPreScript($fCallback)`

> The callback defined for this function will be ran before an event takes place
> Returns nothing.
> The callback requires exactly two parameters `$sEventName` and `$sEventFuncName`

* `_Io_setEventPostScript($fCallback)`

> The callback defined for this function will be ran before an event takes place
> Returns nothing.
> The callback requires exactly two parameters `$sEventName` and `$sEventFuncName`


* `_Io_getVer()`

>
> Returns the current (semantic version)[http://semver.org/] of the UDF
>

* `_Io_On(Const $sEventName, Const $fCallback, $socket = $__g_io_mySocket)`

> Binds an event.
> Returns nothing.
> `$fCallback` has to be an actual function reference. No strings!

* `_Io_Emit(ByRef $socket, $sEventName, $p1, $p2, ...$p16)`

> Emits an event to the given socket.
> Returns nothing.
> Only `1D-Arrays, Ints, Floats, Doubles, Ptrs, Binarys, Strings, Null-keywords or Bools` should be used as parameters.

* `_Io_Loop(ByRef $socket, $whoAmI = $__g_io_whoami)`

> The event engine.
> Returns a bool.
> Should only be used as the main While loop. The function will return false if the function `_Io_Disconnect` is invoked

* `_Io_LoopFacade()`

> A substitute for the `_Io_Loop` solution.
> Returns nothing.
> Should only be used with AdlibRegister. If `_Io_Disconnect` is invoked, this facade will also be un-registered. This function will not work properly if more than 1 `_Io_Connect` or `_Io_Listen` exists in the same script.

* `_Io_EnableEncryption($sFileOrKey, $CryptAlgId = $CALG_AES_256)`

> Encrypts data between the server and the client with the use of Autoit's Crypt.au3.
> Returns true if successfully configured, else @error is set.
> The encryption has to be enabled on both sides for it to work.


* `_Io_Disconnect($socket = null)`

> Manually disconnect as Client or server / Disconnects a client (Only when acting as server).
> Returns nothing.
> This function will purge any previously set `_Io_LoopFacade` and cause `_Io_Loop` to return false. If the `$socket` parameter is set when running as a server, the id of that socket will be disconnected

* `_Io_setRecvPackageSize($nPackageSize = 4096)`

> Sets the maxlen for [TCPRecv](https://www.autoitscript.com/autoit3/docs/functions/TCPRecv.htm)
> Returns nothing.
> Is set default to 4096 by both the server and the client.

* `_Io_ClearEvents()`

> Removes all events from the script.
> Returngs nothing.

* `_Io_TransferSocket(ByRef $from, ByRef $to)`

> Transfer the socket id and events to a new Socket.
> Returns nothing

## Default events

#### Server events
* `connection`

> Takes 1 parameter ($socket)

### Client events

* `banned`

> Takes 5 parametsrs `($socket, $created_at, $expires_at, $sReason, $sIssuedBy)`

#### Server and Client events
* `disconnect`

> Takes 1 parameter ($socket)