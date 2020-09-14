## About Serialize
**Serialize** a given value to get it's string representation, that you can later unSerialize back to its original value. Including nested arrays and objects. This is useful for storing and transferring data between applications.

## Limitations
* Mutli dim arrays are not supported

## Examples

#### Basic example
```AutoIt
#include "Serialize.au3"
#include <Array.au3>
; Define some data
Global $array = [1,2,3]
; Serialize
Global $serialized = _Serialize($array)
MsgBox(64, "Serialized data", $serialized)
; Unserialize
Global $unSerialized = _UnSerialize($serialized)
_ArrayDisplay($unSerialized)
```

#### Objects and nesting
```autoit
#include "Serialize.au3"
#include <Array.au3>
; Define some data
Global $preArray = [1, 2, 3]
Global $array = [5, 6, $preArray]
Global $obj = ObjCreate("Scripting.Dictionary")
$obj.add("firstName", "Tarre")
$obj.add("age", 29)
$obj.add("array", $array)
$obj.add("active", True)
; Serialize
Global $serialized = _Serialize($obj)
MsgBox(64, "Serialized data", $serialized)
; Unserialize
Global $unSerialized = _UnSerialize($serialized)
MsgBox(64, "Unserialized data", "firstName = " & $unSerialized.item("firstName") & @LF & "age = " & $unSerialized.item("age") & @LF & "active = " & $unSerialized.item("active"))
Global $array = $unSerialized.item("array")
Global $preArray = $array[2]
_ArrayDisplay($array, "$array")
_ArrayDisplay($preArray, "$preArray")
```