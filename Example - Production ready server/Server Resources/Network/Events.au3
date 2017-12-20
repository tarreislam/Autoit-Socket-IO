#include-once
#include <Callbacks.au3>

Func __Network_Events(ByRef $socket)
	#forceref $socket

	; ~ Default server events
	_Io_On('connection'); => _On_connection
	_Io_On('disconnect'); => _On_disconnect
	_Io_On('flood'); => _On_disconnect

	; ~ User defined events
	_Io_On('loginRequest'); _On_loginRequest

EndFunc