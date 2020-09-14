# Upgrade guide from 2.0.0 to 3.0.0

The only change is internal and wont affect the public API. The change is implementation of [Autoit-Serialize](https://www.autoitscript.com/forum/topic/203728-autoit-serialize/) which breaks the support to 2.x

# Upgrade guide from 1.5.x to 2.0.0

#### Substitute for **_Io_setEventPostScript** and **_Io_setEventPretScript**

 `_Io_setEventPostScript(myFunc)` and `_Io_setEventPretScript(myFunc)` can generate the same effect with `_Io_RegisterMiddleware('*', myFunc)` The wildcard `*`

 `myFunc` also have to change the incomming params from `($sEventName, $fCallbackName)` to `(const $socket, ByRef $params, const $sEventName, ByRef $fCallbackName)`


 #### Global variables

* All global internal variables has been renamed from `$__g_` to `$g__` (I strongly discourage the use of internal functions and or variables, because you would never know if or when I change them)
* `$__e_io_SERVER`, `$__e_io_CLIENT`, `$_IO_LOOP_SERVER`, `$_IO_LOOP_CLIET` has been replaced by `$_IO_SERVER` AND `$_IO_CLIENT` (Tip: Take a look at `_Io_IsServer()` `_Io_IsClient()` or `_Io_WhoAmI()`)