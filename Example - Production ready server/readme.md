### Howto

* Use `Program.au3` as your entry point.
* Put your app logic in `App\*.au3`
* Put your network logic in `Network\Events.au3` and `Network\Callbacks.au3`
* Compile ./Server.au3
* Use [NSSM - the Non-Sucking Service Manager](https://nssm.cc/) to make your server run as a Service.


### Custom server config

Do `server.exe filename.ini` to start the server with a different config.

```
[server]
debug=false
ip=
port=1337

[misc]
DefaultLogFileName=server.log
MinutesBeforeCleanup=5
MinutesBeforeFlushLogs=5
LogLevel=verbose

[connection]
MaxConnections=100000
MaxDeadSocketsBeforeTidy=1000

[packages]
RecvPackageSize=4096
MaxPackageSize=4096

[encryption]
enabled=false
keyOrFile=
algorithm=CALG_AES_256
```

### Exit codes

**Misc**
* 0 = Graceful exit
* 1 = General failure
* 2 = opt-ini file not found

**Encryption related**
* 10 = Encryption key or file does not exist.
* 11 = Failed to startup crypt library
* 12 = Failed to test encryption
* 13 = Failed to test decryption
* 14 = Mismatch in encrypt data

**Connection related**
* 20 = Failed to start the TCP protocol.
* 21 = Invalid IP address
* 22 = Invalid port
* 23 = General error
