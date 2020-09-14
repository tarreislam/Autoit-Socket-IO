#cs
	Copyright (c) 2020 TarreTarreTarre <tarre.islam@gmail.com>
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
#ce
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7
#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _Serialize
; Description ...: Serialize a given value. Supported types (Strings, Arrays, Scripting Dictionaries, Ints, Doubles, Booleans, Null, PTRs).
; Syntax ........: _Serialize(Const $source)
; Parameters ....: $source              - [const] a string value.
; Return values .: A string representation of the given value
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......: Arrays and Scripting Dictionaries may be nested. Multi DIM arrays are not supported
; Related .......: _UnSerialize
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Serialize(Const $source)
	Return StringTrimRight(__Serialize_Serialize($source), 1)
EndFunc   ;==>_Serialize

; #FUNCTION# ====================================================================================================================
; Name ..........: _UnSerialize
; Description ...: UnSerialize a previously serialized string, restoring its value
; Syntax ........: _UnSerialize(Const $source)
; Parameters ....: $source              - [const] a string value.
; Return values .: Mixed
; Author ........: TarreTarreTarre
; Modified ......:
; Remarks .......:
; Related .......: _Serialize
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UnSerialize(Const $source)
	Local Const $parts = StringSplit($source, "#")

	For $i = 1 To $parts[0]
		Local $part = StringSplit($parts[$i], '|', 2)
		Local $type = $part[0]
		Local $val = $part[1]

		Switch $type
			Case "s"
				Return BinaryToString($val)
			Case "a"
				Return __Serialize_UnSerializeArray($val)
			Case "o"
				Return __Serialize_UnSerializeScriptingDictionary($val)
			Case "b"
				Return $val == 1
			Case "Int32"
				Return Number($val, 1)
			Case "Int64"
				Return Number($val, 2)
			Case "Ptr"
				Return Ptr($val)
			Case "Binary"
				Return Binary($val)
			Case "Double"
				Return Number($val, 3)
			Case "Keyword"
				Return Null
		EndSwitch

	Next

EndFunc   ;==>UnSerialize

; # Native serialize helpers
Func __Serialize_Serialize(Const $source, Const $glue = "#")
	Local Const $type = VarGetType($source)

	Switch $type
		Case $type == "Object" ;This will give performence issues xD And ObjName($source) == "Dictionary"
			Return "o|" & __Serialize_SerializeScriptingDictionary($source) & $glue
		Case $type == "Array"
			Return "a|" & __Serialize_SerializeArray($source) & $glue
		Case "Bool"
			Return "b|" & ($source ? 1 : 0) & $glue
		Case "String"
			Return "s|" & StringToBinary($source) & $glue
		Case Else
			Return $type & "|" & $source & $glue
	EndSwitch

EndFunc   ;==>__Serialize_Serialize

Func __Serialize_SerializeScriptingDictionary(Const $obj)
	Local Const $keys = $obj.keys()
	Local Const $values = $obj.items()
	Local Const $count = $obj.count()
	Local $serialized = ""

	For $i = 0 To $count - 1
		Local $key = $keys[$i]
		Local $value = $values[$i]
		; $key was stringToBinaried
		$serialized &= StringFormat('%s:%s', $key, __Serialize_Serialize($value, '$'))
	Next

	$serialized = $count > 0 ? StringTrimRight($serialized, 1) : $serialized
	$serialized = StringToBinary($serialized)

	Return $serialized
EndFunc   ;==>__Serialize_SerializeScriptingDictionary

Func __Serialize_SerializeArray(Const $array)
	Local Const $count = UBound($array)
	Local $serialized = ""

	For $i = 0 To $count - 1
		$serialized &= __Serialize_Serialize($array[$i], '$')
	Next

	$serialized = $count > 0 ? StringTrimRight($serialized, 1) : $serialized
	$serialized = StringToBinary($serialized)

	Return $serialized

EndFunc   ;==>__Serialize_SerializeArray

Func __Serialize_UnSerializeScriptingDictionary(Const $var)
	Local Const $oObj = ObjCreate("Scripting.Dictionary")
	Local Const $payload = BinaryToString($var)

	If Not $payload Then Return $oObj ; no key val in payload

	Local Const $parts = StringSplit($payload, "$")

	For $i = 1 To $parts[0]
		Local $part = StringSplit($parts[$i], ":", 2)
		Local $key = $part[0] ; BinaryToString wrap will cause performece issues, but this is more unsafe.
		Local $val = _UnSerialize($part[1])
		$oObj.add($key, $val)
	Next

	Return $oObj

EndFunc   ;==>__Serialize_UnSerializeScriptingDictionary

Func __Serialize_UnSerializeArray(Const $array)
	Local Const $payload = BinaryToString($array)
	Local Const $parts = StringSplit($payload, "$")
	Local $aNew[$parts[0]]

	For $i = 1 To $parts[0]
		$aNew[$i - 1] = _UnSerialize($parts[$i])
	Next

	Return $aNew
EndFunc   ;==>__Serialize_UnSerializeArray
