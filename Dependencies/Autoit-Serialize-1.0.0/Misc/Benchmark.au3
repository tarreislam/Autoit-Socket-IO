#include "../Serialize.au3"

Global Const $maxSeconds = 30
Global $timer
Global $iterations
; for lulz

; Create small payload
Local $obj = StaticPayload()
Local $serializedObj = _Serialize($obj)

; If any autoit magic exists, it will be execuded first
_UnSerialize($serializedObj)

ConsoleWrite(@LF & @LF)

ConsoleWrite("!" & @TAB & "Serialized len = " & StringLen($serializedObj) & @LF)

ResetTimers()
While TimerDiff($timer) < $maxSeconds * 1000
	_Serialize($obj)
	$iterations += 1
WEnd
DisplayResult("Serialize")

ResetTimers()
While TimerDiff($timer) < $maxSeconds * 1000
	_UnSerialize($serializedObj)
	$iterations += 1
WEnd
DisplayResult("UnSerialize")

ResetTimers()
While TimerDiff($timer) < $maxSeconds * 1000
	_UnSerialize(_Serialize($obj))
	$iterations += 1
WEnd
DisplayResult("Serialize+UnSerialize")

ResetTimers()
While TimerDiff($timer) < $maxSeconds * 1000
	_UnSerialize(_Serialize(RandomPayload()))
	$iterations += 1
WEnd
DisplayResult("Serialize+UnSerialize random payload")

ConsoleWrite(@LF & @LF)

Func ResetTimers()
	$timer = TimerInit()
	$iterations = 0
EndFunc

Func DisplayResult($name)
	ConsoleWrite("!" & @TAB & $name & ". IPS: " & Round($iterations / (TimerDiff($timer) / 1000), 2) & " @ " & $maxSeconds & " seconds" & @LF)
EndFunc

Func StaticPayload()
	Local $obj = ObjCreate("Scripting.Dictionary")
	Local $obj2 = ObjCreate("Scripting.Dictionary")
	Local $arr = [1, "tarre hehe", 0x1337, 10.5]
	$obj2.add("name", "Tarre")
	$obj2.add("testNull", Null)
	$obj.add("test", "1337")
	$obj.add("array", $arr)
	$obj.add("person", $obj2)
	Return $obj
EndFunc   ;==>StaticPayload

Func RandomPayload($deeper = True)
	Switch Random(0, 9, 1)
		Case 0
			Return Random(1, 255, 1)
		Case 1
			Return Random(1, 255, 0)
		Case 2
			Local $str = ""
			Local $nMax = Random(1, 255, 1)
			For $i = 0 To $nMax
				$str &= Chr(Random(Asc("A"), Asc("Z"), 1))
			Next
			Return $str
		Case 3
			Return Random(0, 1, 1) == 1
		Case 4
			Return Number(Random(1, 255, 1), 1)
		Case 5
			Return Number(Random(999999, 9999999, 1), 2)
		Case 6
			Return Number(Random(1, 9999, 0), 2)
		Case 7
			Return Hex(Random(1, 255, 1), Random(1, 10, 1))
		Case 8
			Local $nMax = Random(1, 255, 1)
			Local $arr[$nMax + 1] = [$nMax]

			For $i = 0 To $nMax
				$arr[$i] = $deeper ? RandomPayload(False) : Random(1, 10, 1)
			Next

			Return $arr
		Case 9
			Local $nMax = Random(1, 255, 1)
			Local $obj = ObjCreate("Scripting.Dictionary")

			For $i = 0 To $nMax
				$obj.add("key" & $i, $deeper ? RandomPayload(False) : Random(1, 10, 1))
			Next

			Return $obj
	EndSwitch
EndFunc   ;==>RandomPayload
