# Autoit-Socket-IO

### Introduction
Autoit-Socket-IO is a event driven TCP/IP wrapper heavily inspired from [Socket.IO](https://socket.io/) with focus on user friendliness and long term sustainability.

I created this UDF because I was fascinated how _Socket.IO_ made a such scary task "reliable and secure networking" so simple for the developer. So this was my main motivation.

I constantly want to make this UDF faster and better, so if you have any suggestions. Do not hesitate

### Features
* Flexiable and easy to understand API
* Above avarage documentation
* "Fully featured" examples
* Security in form of data encryption and middleware-support

### Limitations
* Speed. Because I want this UDF to be as flexible and simple as possible. Sometimes speed is sacrificed, but that does not mean i don't try to .
* ~~It is not possible to emit objects mainly because autoit does not support serialization.~~ (The UDF can now serialize [Scripting Dictionaries](https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/dictionary-object) thanks to [Autoit-Serialize](https://www.autoitscript.com/forum/topic/203728-autoit-serialize/))
* Only 1D-arrays can be emitted (**2D arrays will probably never be supported**)

### Success story
Since December 2017-now I have used version 1.5.0 in an production environment for 40+ clients with great success, the only downtime is planned windows updates and power outages.

### Getting started
* Download the script from AutoIt or pull it from the official github repo `git@github.com:tarreislam/Autoit-Socket-IO.git` and checkout the tag `3.0.0`
* The documentation is located at `Docs\index.html`
* Take a look in the `examples/` folder

### Changelog

**Version 3.0.0** (This update break scripts. Please consult the [upgrade.md](upgrade.md) for guidance)
 * Now supports serialization [Scripting Dictionaries](https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/dictionary-object)
 * Added UnitTester UDF to the mix
 * This is the last version of the current code base.

**Version 2.0.0** (This update break scripts. Please consult the [upgrade.md](upgrade.md) for guidance)
 * All global internal variables has been renamed.
 * Added a bunch of new API methods: `_Io_RegisterMiddleware`, `_Io_whoAmI`, `_Io_IsClient`, `_Io_IsServer`, `_Io_getAllByProperty` and `_Io_getFirstByProperty` and some more. Read more about these in the documentation.
 * `_Io_socketGetProperty` now has a setter method called `_Io_socketSetProperty` which can be used to set custom properties.
 * `_Io_socketGetProperty` now has a third parameter "default" which is used when a property is not found
 * Removed `_Io_setEventPostScript` and `_Io_setEventPretScript` in favor of `_Io_RegisterMiddleware`
 * Improved documentation (It still needs some love though)
 * Improved the verbosity of `_Io_DevDebug`
