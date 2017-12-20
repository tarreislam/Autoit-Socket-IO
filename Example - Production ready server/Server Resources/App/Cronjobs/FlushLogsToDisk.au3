#include-once
;	/*
;	|--------------------------------------------------------------------------
;	| FlushLogsToDisk
;	| ----------------
;	| Flushing logs to disk is necessary to free up some memory
;	| Feel free to
;	|--------------------------------------------------------------------------
;	*/
Func _Network_Cronjob_FlushLogsToDisk()
	Local Static $lastNetworkTick = 1; Must be dividable. So 1 or more

	; If the server has an advantage of 3, we flush
	If Server_getServerTickAdvantage($lastNetworkTick) > 3  Then
		_Log_Init()
		If Not @error Then
			_Log('>', 'Flushed logs to disk.')
			; The logs are flushed. Now reach the servers advantage
			Server_reachServerTickAdvantage($lastNetworkTick)
		Else
			_Log('!', StringFormat('Failed to flush logs. Another attempt is scheduled in %d minutes.', $__MinutesBeforeFlushLogs))
		EndIf
	EndIf

EndFunc