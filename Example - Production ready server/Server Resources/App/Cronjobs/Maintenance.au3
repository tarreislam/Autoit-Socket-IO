#include-once

Func _Network_Cronjobs_Maintenance()
	Local Static $lastNetworkTick = 0
	Local Static $timer = TimerInit()
	Local $curNetworkTick = Server_getNetworkTicks()

	If ((TimerDiff($timer) > (60000 * $__MinutesBeforeCleanup)) And ($curNetworkTick > 0 AND $curNetworkTick == $lastNetworkTick)) OR $curNetworkTick > 100000 Then

		If $curNetworkTick > 100000 Then
			_Log('>', 'Ticks are over 99999 Force-cleaing even if were not idle.')
		Else
			_Log('>', StringFormat('No activity for %d minutes. Cleaning up.', $__MinutesBeforeCleanup))
		EndIf

		_Io_TidyUp()
		$timer = TimerInit()
		Server_resetNetworkTicks()
		$lastNetworkTick = 0
	EndIf

	$lastNetworkTick = $curNetworkTick

EndFunc