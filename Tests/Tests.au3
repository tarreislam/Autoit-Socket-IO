#cs
	_UT_Assert(Const $bool, Const $msg = "Assert Failure", Const $erl = @ScriptLineNumber)

	_UT_Is($x1, $is, $x2, $bStrict = True)
	_UT_ArrayElementCountIs($x1, $is, $x2)
	_UT_ArrayContentIsEqual($x1, $x2, $bStrict = True)

	_UT_CompileAndRun($sPath, $nInstances = 1, $p1...$p10 = Default); if instances is > 1 then an array will be returned with pids

	_UT_SetNamespace($sNamespace); Only works if @compiled = 1
	_UT_Has($sKey, $sNamespace = $___g_UT_RunningNamespace)
	_UT_Set($sKey, $sVal, $sNamespace = $___g_UT_RunningNamespace)
	_UT_Get($sKey, $sDefault = Null, $sNamespace = $___g_UT_RunningNamespace)

#ce


Func testFireEvents()
	Global $g__io_events[1000] = [0]
	; Register event
	Local $socketConnectOrListen = 0xB00B5

	__Io_Push3x($g__io_events, "this:_sho uld-.be:OK", test_fakeCallback, $socketConnectOrListen)

	Local $socket = 0xB00B5
	Local $aParams = [1, 'test']
	Local $parentSocket = $socketConnectOrListen
	_UT_Assert(__Io_FireEvent($socket, $aParams, 'this:_sho uld-.be:OK', $parentSocket))
EndFunc

Func test_fakeCallback($socket, $string)
	_UT_Assert(_UT_IS($socket, "equal", 0xB00B5))
	_UT_Assert(_UT_IS($string, "equal", "test"))
EndFunc

Func test_banning()
	; Create some space
	Global $g__io_aBanlist[6] = [0]; This is essentially what the _Io_listen invokes
	Local Const $ip = @IPAddress1

	_Io_Ban($ip)

	_UT_Assert(_UT_IS(_Io_IsBanned($ip), "lesser", 1), "Failed to add " & $ip & " to banlist")
	_Io_Sanction($ip)

	_UT_Assert(_UT_IS(_Io_IsBanned($ip), "equal", False), $ip & " was never removed from banlist.")


EndFunc

Func test_misc()


	Global $g__io_sockets[10000] = [0]
	Local $nSocketsToAdd = 16

	For $i = 1 To $nSocketsToAdd
		__Io_createFakeSocket()
	Next

	Local $nSockets = _Io_getSocketsCount()

	_UT_Assert(_UT_IS($nSockets, 'equal', $nSocketsToAdd), 'The fake socket count is not equal to what _Io_getSocketsCount says...')


EndFunc


Func test_public_basic_ClientServer()
	Local Const $MessageToSendFromServerToClient = "Hi again!"
	Local $timer = TimerInit(), $timeout = False
	; Build and compile a server and a client
	Local $iServer = _UT_CompileAndRun("Tests_Server.au3", 1, $MessageToSendFromServerToClient)
	Local $iClient = _UT_CompileAndRun("Tests_Client.au3")


	While ProcessExists($iServer) and ProcessExists($iClient)
		if TimerDiff($timer) > 10000 Then
			$timeout = True
			ExitLoop
		EndIf
	WEnd
	ProcessClose($iClient)
	ProcessClose($iServer)

	; Only to make this easier to read.
	Local Const $bStrict = False

	_UT_Assert(Not $timeout, 'A occurred occured when waiting for server and client to shutdown')

	_UT_Assert(_UT_Is(_UT_GET("@server client connected to server", False), "equal", True, $bStrict))
	_UT_Assert(_UT_Is(_UT_GET("@server client disconnected from server", False), "equal", False, $bStrict))
	_UT_Assert(_UT_Is(_UT_GET("@server server recvd message from client", False), "equal", True, $bStrict))
	_UT_Assert(_UT_Is(_UT_GET("@server server started", False), "equal", True, $bStrict))
	_UT_Assert(_UT_Is(_UT_GET("@client client connected to server", True), "equal", True, $bStrict))
	_UT_Assert(_UT_Is(_UT_GET("@client client disconnected from server", False), "equal", True, $bStrict))
	_UT_Assert(_UT_Is(_UT_GET("@client client recvd message from server", True), "equal", True, $bStrict))
	_UT_Assert(_UT_Is($MessageToSendFromServerToClient, "equal", _UT_Get("@welcome message")), "The message sent from server could not be read properly")

EndFunc


Func test_public_basic_ClientServer_With_Encryption()
	Local Const $MessageToSendFromServerToClient = "Hi again!"
	Local $timer = TimerInit(), $timeout = False
	_UT_Cleanup()

	; Create some key
	FileDelete("key.txt")
	FileWrite("key.txt", _Crypt_DeriveKey("My super Secret password", $CALG_AES_256))

	Local $iServer = _UT_CompileAndRun("Tests_Encrypt_Server.au3", 1, $MessageToSendFromServerToClient)
	Local $iClient = _UT_CompileAndRun("Tests_Encrypt_Client.au3")

	While ProcessExists($iServer) and ProcessExists($iClient)
		if TimerDiff($timer) > 10000 Then
			$timeout = True
			ExitLoop
		EndIf
	WEnd

	ProcessClose($iClient)
	ProcessClose($iServer)

	_UT_Assert(Not $timeout, 'A timeout occurred when waiting for server and client to shutdown')
	_UT_Assert(_UT_Is($MessageToSendFromServerToClient, "equal", _UT_Get("@welcome message")), "The message sent from server could not be read properly")

EndFunc

#include <Array.au3>

Func test_Public_Broadcast_ToMultiple_Clients()

	; Because this is a Broadcast and not a Broadcast TO ALL\Emit, this will cause our script only to ignore the7 first client only). So were testing
	Local Const $cnClientsToStart = 25
	Local $timer = TimerInit(), $timeout = False
	_UT_Cleanup()

	Local $iServer = _UT_CompileAndRun("Tests_Server2.au3", 1, $cnClientsToStart, "broadcast"); We pass the amount, so we can exit the server when we hit that amount
	Local $iClients = _UT_CompileAndRun("Tests_Client2.au3",  $cnClientsToStart);

	While ProcessExists($iServer)
		if TimerDiff($timer) > 10000 Then
			$timeout = True
			ExitLoop
		EndIf
	WEnd

	ProcessClose($iServer)

	; It has to be exactly 1 failure here
	Local $nMaxFailures = 0
	For $i = 1 To $iClients[0]
		Local $nPid = $iClients[$i]
		ProcessClose($nPid)
		Local $bHasPid = _UT_Has($nPid)

		If Not $bHasPid Then $nMaxFailures+=1
	Next

	_UT_Assert(_UT_Is($nMaxFailures, "equal or greater", 1), 'The broadcast should only cause exactly 1 failures, instead ' & $nMaxFailures & " were caused")

	_UT_Assert(Not $timeout, 'A timeout occurred when waiting for server or client to shutdown')
EndFunc


Func test_Public_Broadcast_To_All_Clients()

	; This is the exact same test as above but this one uses BroadcastToAll instead of just the regular Broadcast and the error-rate has to be exactly 0
	; Because this is a Broadcast and not a Broadcast TO ALL\Emit, this will cause our script only to ignore the7 first client only). So were testing
	Local Const $cnClientsToStart = 25
	Local $timer = TimerInit(), $timeout = False
	_UT_Cleanup()

	Local $iServer = _UT_CompileAndRun("Tests_Server2.au3", 1, $cnClientsToStart, "broadcast to all"); We pass the amount, so we can exit the server when we hit that amount
	Local $iClients = _UT_CompileAndRun("Tests_Client2.au3",  $cnClientsToStart);

	While ProcessExists($iServer)
		if TimerDiff($timer) > 10000 Then
			$timeout = True
			ExitLoop
		EndIf
	WEnd

	ProcessClose($iServer)

	; It has to be exactly 1 failure here
	Local $nMaxFailures = 0
	For $i = 1 To $iClients[0]
		Local $nPid = $iClients[$i]
		ProcessClose($nPid)
		Local $bHasPid = _UT_Has($nPid)

		If Not $bHasPid Then $nMaxFailures+=1
	Next

	_UT_Assert(_UT_Is($nMaxFailures, "equal", 0), 'The broadcast should only cause exactly 0 failures, instead ' & $nMaxFailures & " were caused")

	_UT_Assert(Not $timeout, 'A timeout occurred when waiting for server or client to shutdown')
EndFunc

Func test_public_BroadCast_to_subscriptions()

	; Because this is a Broadcast and not a Broadcast TO ALL\Emit, this will cause our script only to ignore the7 first client only). So were testing
	Local Const $cnClientsToStart = 4
	Local $timer = TimerInit(), $timeout = False
	_UT_Cleanup()

	Local $iServer = _UT_CompileAndRun("Tests_Subscriptions_Server.au3")
	Local $iClients = _UT_CompileAndRun("Tests_Subscriptions_Client.au3",  $cnClientsToStart);

	While ProcessExists($iServer)
		if TimerDiff($timer) > 10000 Then
			$timeout = True
			ExitLoop
		EndIf
	WEnd

	ProcessClose($iServer)


	Local $helloAs = 0
	Local $helloBs = 0
	For $i = 1 To $iClients[0]
		Local $nPid = $iClients[$i]
		ProcessClose($nPid)
		Local $sData = _UT_Get($nPid)

		If $sData == "Hello from Room A" Then $helloAs +=1
		If $sData == "Hello from Room B" Then $helloBs +=1

	Next

	_UT_Assert(_UT_Is($helloAs, "equal", 2), 'Did not get broadcasts from Room A')
	_UT_Assert(_UT_Is($helloBs, "equal", 2), 'Did not get broadcasts from Room B')

	_UT_Assert(Not $timeout, 'A timeout occurred when waiting for server or client to shutdown')
EndFunc


Func test_public_TidyUp()
	Local Const $nMax = 100
	Local $timer = TimerInit(), $timeout = False
	_UT_Cleanup()


	Local $iServer = _UT_CompileAndRun("Tests_Tidyup_Server.au3", 1, $nMax); The second parameter will se the Maximum sockets
	_UT_CompileAndRun("Tests_Subscriptions_Client.au3",  $nMax);


	While ProcessExists($iServer)
		if TimerDiff($timer) > 40000 Then
			$timeout = True
			ExitLoop
		EndIf
	WEnd

	If $timeout Then
		_UT_Assert(False, 'A timeout occurred when waiting for server or server to shutdown')
	EndIf


	_UT_Assert(_UT_Is(_UT_Get('_Io_getDeadSocketCount'), 'equal', 0, False), 'Automatic tidyup did not work correctly')

EndFunc


Func test_GetAndSetCustomProperties()

	; Setup
	_Io_setPropertyDomainPrefix("test")
	Local $socket = __Io_createFakeSocket()

	_Io_socketSetProperty($socket, 'testProperty', 1337)
	_Io_socketSetProperty($socket, 'testProperty invalid', 1337)

	Local $retrievedValue = _Io_socketGetproperty($socket, 'testProperty', False)
	Local $retrievedValueInvalid = _Io_socketGetproperty($socket, 'testProperty invalid', False)

	_UT_Assert(_UT_Is($retrievedValue, "equal", 1337), "$retrievedValue (" & $retrievedValue & ') is not equal to 1337')
	_UT_Assert(_UT_Is($retrievedValueInvalid, "equal", False), "$retrievedValue (" & $retrievedValue & ') is not equal to 1337')

EndFunc


Func test_SearchForProperties()

	; Setup
	_Io_setPropertyDomainPrefix("test")
	Local $names[5] = ['Bill', 'Bob', 'Nancy', 'Yousef', 'Nyugi']
	Local $locations[5] = ['NY', 'NY', 'NY', 'SE', 'DK']

	; Create some persons and places
	For $i = 0 To 4
		Local $socket = __Io_createFakeSocket()
		_Io_socketSetProperty($socket, 'userId', $i + 1)
		_Io_socketSetProperty($socket, 'name', $names[$i])
		_Io_socketSetProperty($socket, 'location', $locations[$i])
	Next

	; Find Yousef by id and validate his name and location

	Local $results = _Io_getFirstByProperty('userId', 4, 'name,location')
	_UT_Assert(_UT_Is($results[1], "equal", 'Yousef'))
	_UT_Assert(_UT_Is($results[2], "equal", 'SE'))

	; Find all userIds and names by location
	$results = _Io_getAllByProperty('location', 'NY', 'userId,name')

	Local $resultA = $results[1]
	Local $resultB = $results[2]
	Local $resultC = $results[3]


	_UT_Assert(_UT_Is($resultA[1], "equal", 1))
	_UT_Assert(_UT_Is($resultA[2], "equal", 'Bill'))

	_UT_Assert(_UT_Is($resultB[1], "equal", 2))
	_UT_Assert(_UT_Is($resultB[2], "equal", 'Bob'))

	_UT_Assert(_UT_Is($resultC[1], "equal", 3))
	_UT_Assert(_UT_Is($resultC[2], "equal", 'Nancy'))


EndFunc

Func testWhoAmI()

	$g__io_whoami = $_IO_SERVER

	_UT_Assert(_UT_Is(_Io_IsServer(), "equal", True))
	_UT_Assert(_UT_Is(_Io_IsClient(), "equal", False))
	_UT_Assert(_UT_Is(_Io_whoAmI(), "equal", $_IO_SERVER))
	_UT_Assert(_UT_Is(_Io_whoAmI(true), "equal", "SERVER"))

	; Switch it up

	$g__io_whoami = $_IO_CLIENT

	_UT_Assert(_UT_Is(_Io_IsServer(), "equal", False))
	_UT_Assert(_UT_Is(_Io_IsClient(), "equal", True))
	_UT_Assert(_UT_Is(_Io_whoAmI(), "equal", $_IO_CLIENT))
	_UT_Assert(_UT_Is(_Io_whoAmI(true), "equal", "CLIENT"))

EndFunc


Func testAdministrationOfMiddleWares()


	; Register some middlewares

	_Io_RegisterMiddleware("connect", __MmiddlewareCallback)
	_Io_RegisterMiddleware("connect", __MmiddlewareCallback)
	_Io_RegisterMiddleware("disconnect", __MmiddlewareCallback)

	_UT_Assert(_UT_Is($g__io_aMiddlewares[0], "equal", 3))

	_Io_unRegisterMiddleware("connect", __MmiddlewareCallback); 2 should be removed

	; After rebuild
	_Io_TidyUp()
	_UT_Assert(_UT_Is($g__io_aMiddlewares[0], "equal", 0))

	; Try super cleaner
	_Io_RegisterMiddleware("connect", __MmiddlewareCallback)
	_Io_RegisterMiddleware("connect", __MmiddlewareCallback)
	_Io_RegisterMiddleware("disconnect", __MmiddlewareCallback)

	_Io_unRegisterEveryMiddleware()
	_Io_TidyUp()
	_UT_Assert(_UT_Is($g__io_aMiddlewares[0], "equal", 0))

EndFunc


Func __MmiddlewareCallback(Const $socket, ByRef $params, Const $sEventName, ByRef $sEventCallbackName)
	#forceref $socket, $params, $sEventCallbackname, $sEventName
	Return True
EndFunc


Func __MmiddlewareCallbackFalse(Const $socket, ByRef $params, Const $sEventName, ByRef $sEventCallbackName)
	#forceref $socket, $params, $sEventCallbackname, $sEventName
	Return False
EndFunc


Func TestMiddleWareEvent()

	; Setup
	Local $socket = __Io_createFakeSocket()
	_Io_On('eventA', __On_eventA, $socket)
	_Io_On('eventB', __On_eventB, $socket)
	_Io_RegisterMiddleware("eventA", __MmiddlewareCallbackFalse)
	_Io_RegisterMiddleware("eventB", __MmiddlewareCallback)


	Local $params = [123, 456]

	_UT_Assert(_UT_Is(__Io_FireEvent($socket, $params, 'eventA', $socket), "equal", False))
	_UT_Assert(_UT_Is(__Io_FireEvent($socket, $params, 'eventB', $socket), "equal", True))

EndFunc

Func __On_eventA(Const $socket, $payload)
	#forceref $socket, $payload
EndFunc

Func __On_eventB(Const $socket, $payload)
	#forceref $socket, $payload
EndFunc