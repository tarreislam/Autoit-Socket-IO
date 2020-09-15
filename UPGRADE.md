For 2.x and 3.x upgrade help please checkout the [3.x branch](https://github.com/tarreislam/Autoit-Socket-IO/blob/3.x/upgrade.md)

# Upgrade guide from _2.x.x_ and _3.x.x_ to 4.0.0-beta

I will try to cover all changes made

###### Estimated Upgrade Time: 10 minutes

#### API syntax changes

**Likelihood Of Impact: Medium**

Because the API function __Io_Reconnect_ is removed, the `$bAutoReconnect ` parameter becomes obselete.

* **_Io_Connect($sAddress, $iPort, $bAutoReconnect = True)** changed into **_Io_Connect($sAddress, $iPort)**
* **_Io_Listen($iPort, $sAddress = @IPAddress1, $iMaxPendingConnections = Default, $iMaxDeadSocketsBeforeTidy = 1000, $iMaxConnections = 100000)** changed into **_Io_Listen($iPort, $sAddress = @IPAddress1, $iMaxPendingConnections = Default)**
* Default value for `_Io_SetRecvPackageSize` changed from `4096` to `8192`
* `_Io_getSockets()` now returns a scripting object containing all connected sockets and their properties. Read more about how Scripting Dictionaries work [here](https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/dictionary-object)
* **_Io_getSockets($bForceUpdate = False, $socket = $g__io_mySocket, $whoAmI = $g__io_whoami)** changed into  `_Io_getSockets()`
* 

#### Removed API functions

**Likelihood Of Impact: Very High**

This list might change in the non-beta release but for now, these API functions are no longer available because they are replaced by something cooler, or that they does not exist in the core UDF.

* **_Io_Ban** _(Might come back as a optinal feature)_
* **_Io_getBanlist** _(Might come back as a optinal feature)_
* **_Io_Sanction** _(Might come back as a optinal feature)_
* **_Io_IsBanned** _(Might come back as a optinal feature)_
* **_Io_getMaxConnections** 
* **_Io_getMaxDeadSocketsCount**
* **_Io_getSocketsCount**
* **_Io_getFirstByProperty**
* **_Io_getActiveSocketCount** *(A substitute to this would be to call `Io_getSockets().count()`)*
* **_Io_socketGetProperty** (A substitute to this would be to call `Io_getSockets().item($socket).item("propName")`)
* **_Io_socketSetProperty** (A substitute to this would be to call `Io_getSockets().item($socket).add("CustomPropName", "customValue")`)
* **_Io_getSocketsCount**
* **_Io_TransferSocket**
* **_Io_TidyUp** _Since we moved from arrays to Scripting Dictionaries, we no longer have to "Tidy up", that is done automagicly thanks to our events_
* **_Io_Reconnect**
* **_Io_RegisterMiddleware** _(use event listeners instead, checkout the [Docs/EVENTS.md](Docs/EVENTS.md) file for more information)_
* **_Io_unRegisterMiddleware**
* **_Io_unRegisterEveryMiddleware**

#### Decoupling of previous core API into optional features

**Likelihood Of Impact: Low**

Because of the source code decoupling, some API functions may be excluded in your project to minimize bloat.

`SocketIO.au3` now only contains the MIT license and some `#includes` the actual code is now stored in `SocketIO-Core.au3` giving you the opportunity to exclude some functionality .

* **_Io_Emit**
* **_Io_Broadcast**
* **_Io_BroadcastToAll**
* **_Io_getSubscriberRooms**
* **_Io_Subscribe**
* **_Io_UnSubscribe**
* **_Io_UnsubscribeFromAll**
* **_Io_BroadcastToRoom**
* **_Io_DevDebug**

In the [API reference](API.md) you can see where the features are stored.



