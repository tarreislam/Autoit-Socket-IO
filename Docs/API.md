# Documentation / API Reference

[Go back to Documentation](README.md)

## Index

* SocketIO-Core
	* [_Io_getVer](#_Io_getVer)
	* [_Io_whoAmI](#_Io_whoAmI)
	* [_Io_IsServer](#_Io_IsServer)
	* [_Io_IsClient](#_Io_IsClient)
	* [_Io_getSockets](#_Io_getSockets)
	* [_Io_EnableEncryption](#_Io_EnableEncryption)
	* [_Io_setRecvPackageSize](#_Io_setRecvPackageSize)
	* [_Io_setMaxRecvPackageSize](#_Io_setMaxRecvPackageSize)
	* [_Io_setOnPrefix](#_Io_setOnPrefix)
	* [_Io_On](#_Io_On)
	* [_Io_Off](#_Io_Off)
	* [_Io_ClearEvents](#_Io_ClearEvents)
	* [_Io_Listen](#_Io_Listen)
	* [_Io_Connect](#_Io_Connect)
	* [_Io_Loop](#_Io_Loop)
	* [_Io_Disconnect](#_Io_Disconnect)
	* [_Io_FuncGetArgs](#_Io_FuncGetArgs)
	* [_Io_PrepPackage](#_Io_PrepPackage)
	* [_Io_SendPackage](#_Io_SendPackage)
	* [_Io_FireIoEvent](#_Io_FireIoEvent)
* Features\\_Io_Emit
	* [_Io_Emit](#_Io_Emit)
* Features\\_Io_Broadcast
	* [_Io_Broadcast](#_Io_Broadcast)
	* [_Io_BroadcastToAll](#_Io_BroadcastToAll)
* Features\\_Io_Subscriber
	* [_Io_getSubscriberRooms](#_Io_getSubscriberRooms)
	* [_Io_Subscribe](#_Io_Subscribe)
	* [_Io_Unsubscribe](#_Io_Unsubscribe)
	* [_Io_UnsubscribeFromAll](#_Io_UnsubscribeFromAll)
	* [_Io_BroadcastToRoom](#_Io_BroadcastToRoom)
* Features\\_Io_Debug
	* [_Io_DevDebug](#_Io_DevDebug)
	* [_Io_DevDebug_Info](#_Io_DevDebug_Info)
	* [_Io_DevDebug_Success](#_Io_DevDebug_Success)
	* [_Io_DevDebug_Error](#_Io_DevDebug_Error)
* Events\\CommonEvents
	* [_Io_CommonEvents_IoRoleDecided](#_Io_CommonEvents_IoRoleDecided)
	* [_Io_CommonEvents_Initiated](#_Io_CommonEvents_Initiated)
	* [_Io_CommonEvents_Disconnected](#_Io_CommonEvents_Disconnected)
	* [_Io_CommonEvents_Flooded](#_Io_CommonEvents_Flooded)
	* [_Io_CommonEvents_FireEventAttempt](#_Io_CommonEvents_FireEventAttempt)
	* [_Io_CommonEvents_EventFired](#_Io_CommonEvents_EventFired)
	* [_Io_CommonEvents_EventNotFired](#_Io_CommonEvents_EventNotFired)
	* [_Io_CommonEvents_PackageSent](#_Io_CommonEvents_PackageSent)
	* [_Io_CommonEvents_PrepPackage](#_Io_CommonEvents_PrepPackage)
	* [_Io_CommonEvents_PackageRecvd](#_Io_CommonEvents_PackageRecvd)
* Events\\ClientEvents
	* [_Io_ClientEvents_ConnectionAttempt](#_Io_ClientEvents_ConnectionAttempt)
	* [_Io_ClientEvents_FailedToConnect](#_Io_ClientEvents_FailedToConnect)
	* [_Io_ClientEvents_SuccessfullyConnected](#_Io_ClientEvents_SuccessfullyConnected)
	* [_Io_ClientEvents_DisconnectedFromServer](#_Io_ClientEvents_DisconnectedFromServer)
* Events\\ServerEvents
	* [_Io_ServerEvents_ListenAttempt](#_Io_ServerEvents_ListenAttempt)
	* [_Io_ServerEvents_FailedToListen](#_Io_ServerEvents_FailedToListen)
	* [_Io_ServerEvents_ListenSucceded](#_Io_ServerEvents_ListenSucceded)
	* [_Io_ServerEvents_ClientConnected](#_Io_ServerEvents_ClientConnected)
	* [_Io_ServerEvents_ClientDisconnected](#_Io_ServerEvents_ClientDisconnected)
* Dependencies\\Autoit-Serialize-1.0.0\\Serialize
	* [_Serialize](#_Serialize)
	* [_UnSerialize](#_UnSerialize)
* Dependencies\\Autoit-Events-1.0.0\\Event
	* [_Event_GetAll](#_Event_GetAll)
	* [_Event](#_Event)
	* [_Event_Listen](#_Event_Listen)
	* [_Event_RemoveAll](#_Event_RemoveAll)
	* [_Event_Remove](#_Event_Remove)
	* [_Event_RemoveListener](#_Event_RemoveListener)

### <a id="_Io_getVer"></a> _Io_getVer

**Syntax**

```autoit
_Io_getVer()
```

**Description**

Returns the version of the UDF

**Returns**

SEMVER string (X.Y.Z)

**Remarks**

See more on semver @ http://semver.org/

**Related**



### <a id="_Io_whoAmI"></a> _Io_whoAmI

**Syntax**

```autoit
_Io_whoAmI([$verbose = false])
```

**Description**

Returns either `$_IO_SERVER` for server or `$_IO_CLIENT` for client

**Returns**

Bool|String

**Remarks**

This value is changed when invoking _Io_listen and _Io_Connect. If you set $verbose to `true`. This function retruns either "SERVER" or "CLIENT" instead of the constants

**Related**

_Io_listen, _Io_Connect, _Io_IsServer, _Io_IsClient

### <a id="_Io_IsServer"></a> _Io_IsServer

**Syntax**

```autoit
_Io_IsServer()
```

**Description**

Determines if _Io_WhoAmI() == $_IO_SERVER

**Returns**

Bool

**Remarks**

This value is changed when invoking _Io_listen and _Io_Connect

**Related**

_Io_listen, _Io_Connect, _Io_WhoAmI, _Io_IsClient

### <a id="_Io_IsClient"></a> _Io_IsClient

**Syntax**

```autoit
_Io_IsClient()
```

**Description**

Determines if _Io_WhoAmI() == $_IO_CLIENT

**Returns**

Bool

**Remarks**

This value is changed when invoking _Io_listen and _Io_Connect

**Related**

_Io_listen, _Io_Connect, _Io_IsServer, _Io_WhoAmI

### <a id="_Io_getSockets"></a> _Io_getSockets

**Syntax**

```autoit
_Io_getSockets()
```

**Description**

Returns a scripting Dictionary contain all connected sockets and their properties

**Returns**

None

**Remarks**

To access a connected sockets property you can call `_Io_getSockets().item($socketId).item("propName")` Read more in the [Documentation](README.md)

**Related**



### <a id="_Io_EnableEncryption"></a> _Io_EnableEncryption

**Syntax**

```autoit
_Io_EnableEncryption($sFileOrKey)
```

**Description**

Encrypts data before transmission using AutoIt's Crypt.au3

**Returns**

`True` if successfully configured. Null + @error if wrongfully configured. Use @Extended to see which type of internal error is thrown.

**Remarks**

The encryption has to be configured equally on both sides for it to work.

**Related**



### <a id="_Io_setRecvPackageSize"></a> _Io_setRecvPackageSize

**Syntax**

```autoit
_Io_setRecvPackageSize([$iPackageSize = 8192])
```

**Description**

Sets the maxlen for [TCPRecv](https://www.autoitscript.com/autoit3/docs/functions/TCPRecv.htm)

**Returns**

None

**Remarks**



**Related**

_Io_SetMaxRecvPackageSize

### <a id="_Io_setMaxRecvPackageSize"></a> _Io_setMaxRecvPackageSize

**Syntax**

```autoit
_Io_setMaxRecvPackageSize([$iMaxPackageSize = $g__io_nPacketSize])
```

**Description**

Sets the maxibum binarylen is allowed to be received in a single package.

**Returns**

None

**Remarks**

By default if this threshold is exceeded, the `flood` event will be dispatched and the rest of the buffer will be ignored

**Related**

_Io_SetRecvPackageSize

### <a id="_Io_setOnPrefix"></a> _Io_setOnPrefix

**Syntax**

```autoit
_Io_setOnPrefix(Const $sPrefix)
```

**Description**

Set the default prefix for `_Io_On` if not passing callback.

**Returns**

@error if invalid prefix

**Remarks**

only function-friendly names are allowed

**Related**

_Io_On

### <a id="_Io_On"></a> _Io_On

**Syntax**

```autoit
_Io_On(Const $sEventName[, $fCallback = Null[, $socket = $g__io_mySocket]])
```

**Description**

Binds an event

**Returns**

None

**Remarks**

If $fCallback is set to null, the function will assume the prefix "_On_" is applied. Eg (_Io_On('test') will look for "Func _On_Test(...)" etc

**Related**

_Io_SetOnPrefix, _Io_Off

### <a id="_Io_Off"></a> _Io_Off

**Syntax**

```autoit
_Io_Off(Const $sEventName[, $socket = $g__io_mySocket])
```

**Description**

Remove a previously bound event

**Returns**

None

**Remarks**



**Related**

_Io_On

### <a id="_Io_ClearEvents"></a> _Io_ClearEvents

**Syntax**

```autoit
_Io_ClearEvents([$socket = $g__io_mySocket])
```

**Description**

Removes all bound events for a given socket

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_Listen"></a> _Io_Listen

**Syntax**

```autoit
_Io_Listen($iPort[, $sAddress = @IPAddress1[, $iMaxPendingConnections = Default[,
```

**Description**

Starts the server for the given port.

**Returns**

None

**Remarks**

_Io_WhoAmI and the other identity roles will work after this function is invoked, even if it fails!

**Related**



### <a id="_Io_Connect"></a> _Io_Connect

**Syntax**

```autoit
_Io_Connect($sAddress, $iPort[, $bAutoReconnect = True])
```

**Description**

Attempts to connect to a Server.

**Returns**

integer. Null + @error if unable to connect.

**Remarks**

_Io_WhoAmI and the other identity roles will work after this function is invoked, even if it fails!

**Related**



### <a id="_Io_Loop"></a> _Io_Loop

**Syntax**

```autoit
_Io_Loop(Const Byref $socket[, $whoAmI = $g__Io_WhoAmI])
```

**Description**

This is the main event handler for Socket IO.

**Returns**

None

**Remarks**

This function must be used in your scripts main loop or in an AdlibRegister, the speed of your network activity is based on how many times _Io_Loop can be executed

**Related**



### <a id="_Io_Disconnect"></a> _Io_Disconnect

**Syntax**

```autoit
_Io_Disconnect([$socket = $g__io_mySocket])
```

**Description**

Disconnect from a server / Disconnect a client / Stop server

**Returns**

None

**Remarks**

If the identiy is `$_IO_CLIENT ` OR if the identity is `$_IO_SERVER` and the param `$socket` is not provided.  `_Io_Loop` will start to return `False`. If the identity is `$_IO_SERVER` and a connected socket is passed into `$socket`, the server will disconnect that socket

**Related**



### <a id="_Io_FuncGetArgs"></a> _Io_FuncGetArgs

**Syntax**

```autoit
_Io_FuncGetArgs(Byref $aParams[, $nParamsToUse = 0])
```

**Description**

This is the closest thing i can think of to emulate php's "func_get_args", To understand this code, please look in Features\_Io_Emit.au3

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_PrepPackage"></a> _Io_PrepPackage

**Syntax**

```autoit
_Io_PrepPackage(Const $sEventName, Const $aData)
```

**Description**

Returns a prepared package to be sent with _Io_SendPackage

**Returns**

"Socket-Io-package"

**Remarks**



**Related**

_Io_SendPackage

### <a id="_Io_SendPackage"></a> _Io_SendPackage

**Syntax**

```autoit
_Io_SendPackage(Const $socket, Byref $serialized)
```

**Description**

Sends a previously created package to a given socket.

**Returns**

TcpSend -> BytesSent

**Remarks**



**Related**

_Io_PrepPackage

### <a id="_Io_FireIoEvent"></a> _Io_FireIoEvent

**Syntax**

```autoit
_Io_FireIoEvent(Const $eventName, $eventData, Const Byref $socket, Const Byref $mySocket)
```

**Description**

The UDFS internal event observers. Fire events to previously registred events (`_Io_on('evtName', cb)`)

**Returns**

None

**Remarks**

This function has nothing to do with `_Event` or its functions.

**Related**



### <a id="_Io_Emit"></a> _Io_Emit

**Syntax**

```autoit
_Io_Emit(Const $socket, $sEventName[, $p1 = Default[, $p2 = Default[, $p3 = Default[, $p4 = Default[,
```

**Description**

Emit an event to a given $socket. Mostly used for server to client and client to server communication.

**Returns**

Integer. Bytes sent

**Remarks**

To pass more than 16 parameters, a special array can be passed in lieu of individual parameters. This array must have its first element set to "CallArgArray" and elements 1 - n will be passed as separate arguments to the function. If using this special array, no other arguments can be passed

**Related**

_Io_Broadcast, _Io_BroadcastToAll, _Io_BroadcastToRoom

### <a id="_Io_Broadcast"></a> _Io_Broadcast

**Syntax**

```autoit
_Io_Broadcast(Const $socket, $sEventName[, $p1 = Default[, $p2 = Default[, $p3 = Default[, $p4 = Default[,
```

**Description**

Server-side only. Emit an event every connected socket but not the passed $socket

**Returns**

Integer. Bytes sent

**Remarks**

To pass more than 16 parameters, a special array can be passed in lieu of individual parameters. This array must have its first element set to "CallArgArray" and elements 1 - n will be passed as separate arguments to the function. If using this special array, no other arguments can be passed

**Related**

_Io_Emit, _Io_BroadcastToAll, _Io_BroadcastToRoom

### <a id="_Io_BroadcastToAll"></a> _Io_BroadcastToAll

**Syntax**

```autoit
_Io_BroadcastToAll(Const $socket, $sEventName[, $p1 = Default[, $p2 = Default[, $p3 = Default[, $p4 = Default[,
```

**Description**

Server-side only. Emit an event every connected socket including the passed $socket

**Returns**

Integer. Bytes sent

**Remarks**

To pass more than 16 parameters, a special array can be passed in lieu of individual parameters. This array must have its first element set to "CallArgArray" and elements 1 - n will be passed as separate arguments to the function. If using this special array, no other arguments can be passed

**Related**

_Io_Emit, _Io_Broadcast, _Io_BroadcastToRoom

### <a id="_Io_getSubscriberRooms"></a> _Io_getSubscriberRooms

**Syntax**

```autoit
_Io_getSubscriberRooms()
```

**Description**

Get a list of all subscriber rooms.

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_Subscribe"></a> _Io_Subscribe

**Syntax**

```autoit
_Io_Subscribe(Const $socket, $sRoomName)
```

**Description**

Server-side only. Subscribes a socket to a room.

**Returns**

None

**Remarks**



**Related**

_Io_BroadcastToRoom, _Io_Unsubscribe

### <a id="_Io_Unsubscribe"></a> _Io_Unsubscribe

**Syntax**

```autoit
_Io_Unsubscribe(Const $socket, $sRoomName)
```

**Description**

Server-side only. Unsubscribes a socket from a room.

**Returns**

None

**Remarks**



**Related**

_Io_Subscribe, _Io_UnsubscribeFromAll

### <a id="_Io_UnsubscribeFromAll"></a> _Io_UnsubscribeFromAll

**Syntax**

```autoit
_Io_UnsubscribeFromAll(Const $socket)
```

**Description**

Server-side only. Unsubscribes a socket from all rooms.

**Returns**

None

**Remarks**



**Related**

_Io_Subscribe, _Io_Unsubscribe

### <a id="_Io_BroadcastToRoom"></a> _Io_BroadcastToRoom

**Syntax**

```autoit
_Io_BroadcastToRoom(Const $socket, $sDesiredRoomName, $sEventName[, $p1 = Default[, $p2 = Default[, $p3 = Default[,
```

**Description**

Server-side only. Emit an event to every socket subscribed to a given room

**Returns**

Integer. Bytes sent

**Remarks**

To pass more than 16 parameters, a special array can be passed in lieu of individual parameters. This array must have its first element set to "CallArgArray" and elements 1 - n will be passed as separate arguments to the function. If using this special array, no other arguments can be passed

**Related**

_Io_Emit, _Io_Broadcast, _Io_BroadcastToAll, _Io_Subscribe

### <a id="_Io_DevDebug"></a> _Io_DevDebug

**Syntax**

```autoit
_Io_DevDebug()
```

**Description**

This function will bind important events and report them in both stdOut, stdErr and in files with timestamps and more.

**Returns**

None

**Remarks**

The debugger cannot be disabled after it has been enabled, so be careful to use this in production because the log files will be HUGE.

**Related**



### <a id="_Io_DevDebug_Info"></a> _Io_DevDebug_Info

**Syntax**

```autoit
_Io_DevDebug_Info($str)
```

**Description**

Write string to regular cw (role.log)

**Returns**

None

**Remarks**

This does not require _Io_DevDebug() to be initiated

**Related**



### <a id="_Io_DevDebug_Success"></a> _Io_DevDebug_Success

**Syntax**

```autoit
_Io_DevDebug_Success($str)
```

**Description**

Write string to regular cw (role.log)

**Returns**

None

**Remarks**

This does not require _Io_DevDebug() to be initiated

**Related**



### <a id="_Io_DevDebug_Error"></a> _Io_DevDebug_Error

**Syntax**

```autoit
_Io_DevDebug_Error($str)
```

**Description**

Write string to error cw (role.log)

**Returns**

None

**Remarks**

This does not require _Io_DevDebug() to be initiated

**Related**



### <a id="_Io_CommonEvents_IoRoleDecided"></a> _Io_CommonEvents_IoRoleDecided

**Syntax**

```autoit
_Io_CommonEvents_IoRoleDecided(Const Byref $oEvent)
```

**Description**

This event is fired whenever_Io_Listen or _Io_Connect is called

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_CommonEvents_Initiated"></a> _Io_CommonEvents_Initiated

**Syntax**

```autoit
_Io_CommonEvents_Initiated(Const Byref $oEvent)
```

**Description**

This event is fired if _Io_Connect or _Io_listen succeded

**Returns**

None

**Remarks**

There are also individual events for server and clients

**Related**



### <a id="_Io_CommonEvents_Disconnected"></a> _Io_CommonEvents_Disconnected

**Syntax**

```autoit
_Io_CommonEvents_Disconnected(Const Byref $oEvent, $socket)
```

**Description**

This event is fired if _Io_Disconnect() is called without a given parameter

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_CommonEvents_Flooded"></a> _Io_CommonEvents_Flooded

**Syntax**

```autoit
_Io_CommonEvents_Flooded(Const Byref $oEvent, $connctedSocket)
```

**Description**

This event is fired if the recvd package reaches $g__io_nMaxPacketSize (set by _Io_setMaxRecvPackageSize)

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_CommonEvents_FireEventAttempt"></a> _Io_CommonEvents_FireEventAttempt

**Syntax**

```autoit
_Io_CommonEvents_FireEventAttempt(Const Byref $oEvent, Const Byref $eventName, Const Byref $eventData, Const Byref $socket,
```

**Description**

This event is fired when an attempt of _Io_FireIoEvent is made

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_CommonEvents_EventFired"></a> _Io_CommonEvents_EventFired

**Syntax**

```autoit
_Io_CommonEvents_EventFired(Const Byref $oEvent, Const $eventCallable, Const $eventData)
```

**Description**

This event is fired if the the function callback of _Io_On callable was ran successfully

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_CommonEvents_EventNotFired"></a> _Io_CommonEvents_EventNotFired

**Syntax**

```autoit
_Io_CommonEvents_EventNotFired(Const Byref $oEvent, Const $eventCallable, Const $eventData)
```

**Description**

This event is fired if something caused the event not to be fired

**Returns**

None

**Remarks**

`$reason` can either be `NOT_FOUND` or `0xDEAD_0xBEEF`

**Related**



### <a id="_Io_CommonEvents_PackageSent"></a> _Io_CommonEvents_PackageSent

**Syntax**

```autoit
_Io_CommonEvents_PackageSent(Const Byref $oEvent, Const $bytesSent, Const $tcpSentError)
```

**Description**

This event is fired after after each call of _Io_SendPackage

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_CommonEvents_PrepPackage"></a> _Io_CommonEvents_PrepPackage

**Syntax**

```autoit
_Io_CommonEvents_PrepPackage(Const Byref $oEvent, Const $eventName)
```

**Description**

This event is fired when _Io_PrepPackage is called

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_CommonEvents_PackageRecvd"></a> _Io_CommonEvents_PackageRecvd

**Syntax**

```autoit
_Io_CommonEvents_PackageRecvd(Const Byref $oEvent, Const $bytesRecvd)
```

**Description**

This is event is fired when some kind of data was received via TcpRecv (_Io_Loop)

**Returns**

None

**Remarks**

The event is fired in an internal function called __Io_RecvPackage

**Related**



### <a id="_Io_ClientEvents_ConnectionAttempt"></a> _Io_ClientEvents_ConnectionAttempt

**Syntax**

```autoit
_Io_ClientEvents_ConnectionAttempt(Const Byref $oEvent, Const $sAddress, Const $iPort)
```

**Description**

This event is fired when a connection attempt was made to a given server

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_ClientEvents_FailedToConnect"></a> _Io_ClientEvents_FailedToConnect

**Syntax**

```autoit
_Io_ClientEvents_FailedToConnect(Const Byref $oEvent, $error, $extended)
```

**Description**

This event is fired when TcpConnect failed

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_ClientEvents_SuccessfullyConnected"></a> _Io_ClientEvents_SuccessfullyConnected

**Syntax**

```autoit
_Io_ClientEvents_SuccessfullyConnected(Const Byref $oEvent)
```

**Description**

This event is fired when a connection attempt was successfull

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_ClientEvents_DisconnectedFromServer"></a> _Io_ClientEvents_DisconnectedFromServer

**Syntax**

```autoit
_Io_ClientEvents_DisconnectedFromServer(Const Byref $oEvent, Const $lastUsedIp, Const $lastUsedPort)
```

**Description**

This event is fired if the server disconnected us.

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_ServerEvents_ListenAttempt"></a> _Io_ServerEvents_ListenAttempt

**Syntax**

```autoit
_Io_ServerEvents_ListenAttempt(Const Byref $oEvent)
```

**Description**

This event is fired when _Io_listen is executed

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_ServerEvents_FailedToListen"></a> _Io_ServerEvents_FailedToListen

**Syntax**

```autoit
_Io_ServerEvents_FailedToListen(Const Byref $oEvent, $error, $extended)
```

**Description**

This event is fired if The server failed to listen (TcipListen). error and extended is set

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_ServerEvents_ListenSucceded"></a> _Io_ServerEvents_ListenSucceded

**Syntax**

```autoit
_Io_ServerEvents_ListenSucceded(Const Byref $oEvent)
```

**Description**

This event is fired when a server successfully listens on a given ip:port

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_ServerEvents_ClientConnected"></a> _Io_ServerEvents_ClientConnected

**Syntax**

```autoit
_Io_ServerEvents_ClientConnected(Const Byref $oEvent, $connctedSocket, $mySocket)
```

**Description**

This event is fired when a client connects toa server (TcpAccept)

**Returns**

None

**Remarks**



**Related**



### <a id="_Io_ServerEvents_ClientDisconnected"></a> _Io_ServerEvents_ClientDisconnected

**Syntax**

```autoit
_Io_ServerEvents_ClientDisconnected(Const Byref $oEvent, $connctedSocket, $mySocket)
```

**Description**

This event is fired when a previously connected client disconnects from the server

**Returns**

None

**Remarks**



**Related**



### <a id="_Serialize"></a> _Serialize

**Syntax**

```autoit
_Serialize(Const $source)
```

**Description**

Serialize a given value. Supported types (Strings, Arrays, Scripting Dictionaries, Ints, Doubles, Booleans, Null, PTRs).

**Returns**

A string representation of the given value

**Remarks**

Arrays and Scripting Dictionaries may be nested. Multi DIM arrays are not supported

**Related**

_UnSerialize

### <a id="_UnSerialize"></a> _UnSerialize

**Syntax**

```autoit
_UnSerialize(Const $source)
```

**Description**

UnSerialize a previously serialized string, restoring its value

**Returns**

Mixed

**Remarks**



**Related**

_Serialize

### <a id="_Event_GetAll"></a> _Event_GetAll

**Syntax**

```autoit
_Event_GetAll()
```

**Description**

Return all events

**Returns**

All registred events

**Remarks**



**Related**



### <a id="_Event"></a> _Event

**Syntax**

```autoit
_Event(Const $callableEvent[, $p1 = Default[, $p2 = Default[, $p3 = Default[, $p4 = Default[, $p5 = Default[,
```

**Description**

Dispatch an event with up to 6 params

**Returns**

None

**Remarks**



**Related**

_Event_Listen

### <a id="_Event_Listen"></a> _Event_Listen

**Syntax**

```autoit
_Event_Listen(Const $callableEvent, Const $callableListener)
```

**Description**

Subscribe an listener to a given event

**Returns**

True if event+listener was successfully registred, error if the listener is already registred

**Remarks**



**Related**

_Event_Remove, _Event_RemoveAll, _Event_RemoveListener

### <a id="_Event_RemoveAll"></a> _Event_RemoveAll

**Syntax**

```autoit
_Event_RemoveAll()
```

**Description**

Remove all events and their respective listeners

**Returns**

None

**Remarks**



**Related**

_Event_Listen, _Event_Remove, _Event_RemoveListener

### <a id="_Event_Remove"></a> _Event_Remove

**Syntax**

```autoit
_Event_Remove(Const $callableEvent)
```

**Description**

Remove a specified event with all its listeners

**Returns**

True if an event was found, @error set and false if no event was found

**Remarks**



**Related**

_Event_Listen, _Event_RemoveAll, _Event_RemoveListener

### <a id="_Event_RemoveListener"></a> _Event_RemoveListener

**Syntax**

```autoit
_Event_RemoveListener(Const $callableEvent, $callableListener)
```

**Description**

Remove a listener from an event (Does not remove the event itself)

**Returns**

True if an event was found, @error set and false if no event/listener was found

**Remarks**

Error 1 = event not found. Error 2 = event found, but listener was not found

**Related**

_Event_Listen, _Event_RemoveAll, _Event_Remove

