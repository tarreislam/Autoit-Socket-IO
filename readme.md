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
* It is not possible to Broadcast/Emit objects
* Only 1D-arrays are allowed to be Broadcasted/Emitted (**2D arrays will probably never be supported**)

### Changelog

**Version 1.5.0** (This update **DOES NOT** break scripts)
 * Added AutoIt like docs under `Docs\`. The docs are generated so its a 1 to 1 reflection of the UDF headers. [Print of documentation](https://i.imgur.com/EPnIgSn.png)
 * Added a production ready server example.
 * Added a new method: `_Io_DevDebug` which will display useful information when debugging.
 * Added a new method: `_Io_SetMaxRecvPackageSize` which defaults to whatever `_Io_setRecvPackageSize` is set to.
 * Added a new method: `_Io_setOnPrefix` which defaults to `_On_`
 * Added a new default client & server event called `flood`. Flood occurs when exceeding the `$__g_io_nMaxPacketSize`. `$__g_io_nMaxPacketSize` is set by `_Io_SetMaxRecvPackageSize`
 * Fixed the 16 parameter limit when sending data with `_Io_Emit`, `_Io_Broadcast`, `_Io_BroadcastToAll` and `_Io_BroadcastToRoom`. This works on the same premise that [AutoIt's Call](https://www.autoitscript.com/autoit3/docs/functions/Call.htm) Does
 * Fixed a TRUNCATION problem when receiving packages which could cause crashes!
 * Fixed a programming error which caused `$__g_ionPacketSize` to reset to default `4096` if `_Io_Connect` or `_Io_listen` were called after `_Io_setRecvPackageSize`
 * Fixed `_Io_setEventPreScript` and `_Io_setEventPostScript` They didnt work. Lol.
 * Changed how events are fired so the client cannot crash the server by sending the wrong number of parameters (This also allows for optional parameters on callbacks)
 * Changed `_Io_On`. The second parameter `$fCallback` can now be set to null. Doing this, the function assumes that the callback is: `_On_<eventName>`.

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
 Please see the docs provided

## Default events

#### Server events
* `connection`

> `connection` occurs when an connection has been successfully established
> Takes 1 parameter ($socket)


### Client events

* `banned`

> `banned` occurs when the server issues a `_Io_Ban` on an ip or a socket. The `banned` event will occur upon reconnecting after a `disconnect` event.
> Takes 5 parametsrs `($socket, $created_at, $expires_at, $sReason, $sIssuedBy)`

#### Server and Client events
* `disconnect`

> If server: `disconnect` occurs when a user disconnects. If client: `disconnect` occurs when the conection to the server is lost.
> Takes 1 parameter ($socket)

* `flood`

> `flood` occurs when exceeding the `$__g_io_nMaxPacketSize`. `$__g_io_nMaxPacketSize` is set by `_Io_SetMaxRecvPackageSize` which defaults to whatever `_Io_setRecvPackageSize` is set to.
> Takes 1 parameter ($socket)