#include "../Serialize.au3"

Global Const $tests = [test_var_type_translations, test_obj_restructure, test_arr_restructure, test_nested_restructure_arr_pov]

For $i = 0 To UBound($tests) -1
	Local $test = $tests[$i]
	Local $name = FuncName($test)

	If Not $test() Then
		ConsoleWrite("! Test " & $name & " Failed" & @LF)
	Else
		ConsoleWrite("+ Test " & $name & " Succeded!" & @LF)
	EndIf
Next

Func test_var_type_translations()
	Local $aArray = [1, "Example"]
	Local $dBinary = Binary("0x00204060")
	Local $bBoolean = False
	Local $pPtr = Ptr(-1)
	Local $iInt = 1
	Local $fFloat = 2.0
	Local $oObject = ObjCreate("Scripting.Dictionary")
	Local $sString = "Some text"


	Local $arrTest = VarGetType(_UnSerialize(_Serialize($aArray))) == "Array"
	Local $binaryTest = VarGetType(_UnSerialize(_Serialize($dBinary))) == "Binary"
	Local $booleanTest = VarGetType(_UnSerialize(_Serialize($bBoolean))) == "Bool"
	Local $ptrTest = VarGetType(_UnSerialize(_Serialize($pPtr))) == "Ptr"
	Local $intTest = VarGetType(_UnSerialize(_Serialize($iInt))) == "Int32"
	Local $fFloatTest = VarGetType(_UnSerialize(_Serialize($fFloat))) == "Double"
	Local $oObjTest = VarGetType(_UnSerialize(_Serialize($oObject))) == "Object"
	Local $stringTest = VarGetType(_UnSerialize(_Serialize($sString))) == "String"

	assertTrue($arrTest)
	assertTrue($binaryTest)
	assertTrue($booleanTest)
	assertTrue($ptrTest)
	assertTrue($intTest)
	assertTrue($fFloatTest)
	assertTrue($oObjTest)
	assertTrue($stringTest)

	Return $arrTest AND $binaryTest AND $booleanTest AND $ptrTest AND $intTest AND $fFloat AND $oObjTest AND $stringTest
EndFunc

Func test_obj_restructure()
	Local $o = o()
	With $o
		.add("a", 1)
		.add("b", 2)
		.add("c", 3)
		.add("d", 4)
		.add("e", 5)
	EndWith
	Local $unSerialized = _UnSerialize(_Serialize($o))

	assertTrue($o.item("a") == 1)
	assertTrue($o.item("b") == 2)
	assertTrue($o.item("c") == 3)
	assertTrue($o.item("d") == 4)
	assertTrue($o.item("e") == 5)

	Return True
EndFunc

Func test_arr_restructure()
	Local $a = [1,2,3,4,5]
	Local $unSerialized = _UnSerialize(_Serialize($a))

	assertTrue($unSerialized[0] == 1)
	assertTrue($unSerialized[1] == 2)
	assertTrue($unSerialized[2] == 3)
	assertTrue($unSerialized[3] == 4)
	assertTrue($unSerialized[4] == 5)

	Return True
EndFunc

Func test_nested_restructure_arr_pov()
	Local $tokens = ["billing", "customers"]
	Local $personA = o()
	Local $personB = o()
	With $personA
		.add("name", "test")
		.add("age", 17)
		.add("active", False)
		.add("tokens", $tokens)
	EndWith
	With $personB
		.add("name", "Errat")
		.add("age", 35)
		.add("active", True)
		.add("tokens", $tokens)
	EndWith


	Local $a = [$personA, $personB]
	Local $unSerialized = _UnSerialize(_Serialize($a))

	assertTrue($unSerialized[0].item("name") == "test")
	assertTrue($unSerialized[0].item("age") == 17)
	assertTrue($unSerialized[0].item("active") == False)
	assertTrue($unSerialized[0].item("tokens")[0] == "billing")
	assertTrue($unSerialized[0].item("tokens")[1] == "customers")

	assertTrue($unSerialized[1].item("name") == "Errat")
	assertTrue($unSerialized[1].item("age") == 35)
	assertTrue($unSerialized[1].item("active") == True)
	assertTrue($unSerialized[1].item("tokens")[0] == "billing")
	assertTrue($unSerialized[1].item("tokens")[1] == "customers")

	Return True
EndFunc

Func assertTrue($val, Const $ln = @ScriptLineNumber)
	If $val == True Then Return
	ConsoleWrite("! Failed asserting that " & $val & " is  True on line " & $ln & @LF)
	Exit
EndFunc

Func o()
	Return ObjCreate("Scripting.Dictionary")
EndFunc