
Version 2.x.x and 3.x.x has been moved to [branch 3.x](https://github.com/tarreislam/Autoit-Socket-IO/tree/3.x)

## About Autoit-Socket-IO
Autoit-Socket-IO is a event driven TCP/IP wrapper heavily inspired from [Socket.IO](https://socket.io/) with focus on user friendliness and long term sustainability.

I constantly want to make this UDF faster and better, so if you have any suggestions or questions (beginner and advanced) Do not hesitate to ask them, I will gladly help!

### Key features
* Simple API
* 99% data-type serialization thanks to [Autoit-Serialize](https://www.autoitscript.com/forum/topic/203728-autoit-serialize)
* Can easily be extended with your own functionality thanks to [Autoit-Events](https://www.autoitscript.com/forum/topic/203866-autoit-events/)
* "Educational" examples
* Data encryption thanks to _<Crypt.au3>

### Limitations
* Speed. This UDF will sacrifice some speed for convenience

### Getting started
* Download the script from AutoIt or pull it from the official github repo `git@github.com:tarreislam/Autoit-Socket-IO.git` and checkout the tag `4.0.0-beta`
* Check out the [documentaion](Docs/README.md)
* Take a look in the `examples/` folder

### Changelog
To see changes from 3.x.x and 2.x.x please checkout the [3.x branch](https://github.com/tarreislam/Autoit-Socket-IO/blob/3.x/upgrade.md)

**Version 4.0.0-beta** (This update break scripts.)

 * Code base fully rewritten with [Autoit-Events](https://www.autoitscript.com/forum/topic/203866-autoit-events/) and decoupled to improve code quality and reduce bloat.
 * The new UDF is very different from 3.x.x so please checkout the [UPGRADE guide](https://github.com/tarreislam/Autoit-Socket-IO/blob/master/UPGRADE.md) to fully understand all changes
 * Added new documentation [documentaion](Docs/README.md)

### Success stories
Since December 2017-now I have used version 1.5.0 in an production environment for 150+ clients with great success, the only downtime is planned windows updates and power outages.
