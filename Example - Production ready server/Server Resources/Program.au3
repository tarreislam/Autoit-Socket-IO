#include-once

#include "App\Cronjobs\KERNEL.au3"
;	/*
;	|--------------------------------------------------------------------------
;	| Global Variables
;	| ----------------
;	| Define your applications Global Variables here.
;	|--------------------------------------------------------------------------
;	*/

Global Const $__AppName = "My Server"
Global const $__AppVersion = "1.0.0"

;	/*
;	|--------------------------------------------------------------------------
;	| Program Includes
;	| ----------------
;	| Define your application #include's here. UDFS may be placed in that directory aswell
;	|--------------------------------------------------------------------------
;	*/

#include "App\Functions.au3"

;	/*
;	|--------------------------------------------------------------------------
;	| Main function
;	| ----------------
;	| This function will start when the server has successfully started.
;	|--------------------------------------------------------------------------
;	*/

Func Program(ByRef $socket)
	#forceref $socket

	; Register cronjobs
	AdlibRegister('_Network_Cronjobs_Maintenance', 60000)
	AdlibRegister('_Network_Cronjob_FlushLogsToDisk', (60000 * $__MinutesBeforeFlushLogs))

	_Log('+', StringFormat('Successfully started %s @ %s', _App_getName(), _App_getVersion()))

	; The main loop
	While _Io_Loop($socket)
	WEnd

EndFunc

;	/*
;	|--------------------------------------------------------------------------
;	| Exit function
;	| ----------------
;	| This optional function will be executed before the script exits gracefully
;	|--------------------------------------------------------------------------
;	*/

; Func OnExit()
; 	_Log('!', 'Please come again!')
; EndFunc
