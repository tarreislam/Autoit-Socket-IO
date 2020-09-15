#include <../Dependencies/Autoit-Unittester/UnitTester.au3>
#include <Tests.au3>
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7


;Cleanup
_UT_Cleanup()
; No tests exists
_UT_Cleanup()


; Register how we want to display the result
Func RunnerCallback($sDesiredNamespace, $aResult)

	ConsoleWrite(@CRLF & ">" & @TAB & StringFormat("Ran [%s] with a total of %d tests", $sDesiredNamespace, $aResult[0]) & @CRLF)
	For $i = 1 To $aResult[0]
		Local $aDefault = $aResult[$i]

		Local $sTestName = $aDefault[0]
		Local $aFailures = $aDefault[1]
		Local $nTotalAssertions = $aDefault[2]

		Local $nFailures = $aFailures[0]
		Local $fqdn = StringFormat("%s\%s", $sDesiredNamespace, $sTestName)

		If $nFailures Then
			ConsoleWrite("!" & @TAB & StringFormat("%s failed %d/%d assertions", $fqdn, $nFailures, $nTotalAssertions) & @LF)
			For $j = 1 To $aFailures[0]
				Local $aFailure = $aFailures[$j]
				Local $nLineNumber = $aFailure[0]
				Local $sLineMessage = $aFailure[1]
				ConsoleWrite("-" & @TAB & StringFormat("[Line %d]: %s", $nLineNumber, $sLineMessage) & @LF)
			Next
		Else
			ConsoleWrite("+" & @TAB & $fqdn & " completed successfully" & @CRLF)
		EndIf
	Next
	ConsoleWrite(@CRLF)
EndFunc   ;==>RunnerCallback
