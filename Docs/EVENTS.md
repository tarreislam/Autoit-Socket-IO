# Documentation / Extend Autoit-Socket-IO

[Go back to Documentation](README.md)

## Introduction

Because AutoIt-Socket-IO is built with [Autoit-Events](https://www.autoitscript.com/forum/topic/203866-autoit-events) in its core, its really easy to extend the UDF and make it unique without modifying the source code.

In the [API reference](API.md) you can find all available events, when they are fired and the data they provide to all of their listeners.

### Understanding how events works

If you are not familiar with how events works, here is an "easy to understand" explanation. If you look in the source code of [SocketIO-Core.au3](https://github.com/tarreislam/Autoit-Socket-IO/blob/master/SocketIO-Core.au3) in the function `_Io_SendPackage` you will see a function call `_Event(_Io_CommonEvents_PackageSent, $socket, $bytesSent, @error)`

That code might not make sense at first, but think about this. Lets say you want to count all TCP bytes sent by your application, then you could place a global variable in the function:

```autoit
Local Const $bytesSent = TCPSend($socket, $serialized)
$myGlobalCountr += $bytesSent
```

This will work, but its not even close to optimal, because you cannot update the UDF without breaking your own code and debugging becomes a hassle.

So Instead you can bind listeners to the desired event and invoke your function outside the Autoit-Socket-IO UDF. 

**Example**

```autoit
#include "..\SocketIO.au3"
....
Global $myGlobalCounter = 0; Bytes sent

; Listen for when the _Io_CommonEvents_PackageSent event is sent
; Then call my function "myByteCounterFunction"
_Event_Listen(_Io_CommonEvents_PackageSent, MyByteCounterFunction)

Func MyByteCounterFunction(Const ByRef $oEvent)
	 $myGlobalCounter += $oEvent.item("bytesSent")
EndFunc
```

When you do this, you will not break your own code when the UDF is updated and your code will be nice and tidy.

You can register as many listeners as you want to the same event, they will be executed in order.

In the [API reference](API.md) you can find all available events, when they are fired and the data they provide to all of their listeners.

### Suggestions

If you need help to build some kind of extension or have other questions and suggestions, feel free to ask in the [official thread](https://www.autoitscript.com/forum/topic/188991-autoit-socket-io-networking-in-autoit-made-simple). We both might learn something (:



