#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7
#include "..\socketIO.au3"

If $CmdLine[0] > 0 And Not FileExists($CmdLine[1]) Then
	Exit(2)
EndIf

Global Const $__SettingsFile = $CmdLine[0] > 0 ? $CmdLine[1] : 'settings.ini'
Global Const $__DefaultLogFileName = IniRead($__SettingsFile, 'misc', 'DefaultLogFileName', 'server.log')
Global Const $__LogLevel = IniRead($__SettingsFile, 'misc', 'LogLevel', 'verbose')
Global Const $__MinutesBeforeCleanup = Execute(IniRead($__SettingsFile, 'misc', 'MinutesBeforeCleanup', 5)); Minutes of Inactivity before we TidyUp
Global Const $__MinutesBeforeFlushLogs = Execute(IniRead($__SettingsFile, 'misc', 'MinutesBeforeFlushLogs', 5));; How often we should check if we need to flush
Global Const $__debug = Execute(IniRead($__SettingsFile, 'server', 'debug', Not @Compiled)); This means debug = true if the script is not compiled
Global Const $__iDefaultPort = Execute(IniRead($__SettingsFile, 'server', 'port', 1337))
Global Const $__sDefaultIp = IniRead($__SettingsFile, 'server', 'ip', @IPAddress1)
Global Const $__iMaxDeadSocketsBeforeTidy = Execute(IniRead($__SettingsFile, 'connection', 'MaxDeadSocketsBeforeTidy', 1000))
Global Const $__iMaxConnections = Execute(IniRead($__SettingsFile, 'connection', 'MaxConnections', 100000))
Global Const $__iRecvPackageSize = Execute(IniRead($__SettingsFile, 'packages', 'RecvPackageSize', 4096))
Global Const $__iMaxPackageSize = Execute(IniRead($__SettingsFile, 'packages', 'MaxPackageSize', 4096))
Global Const $__EnableEncryption = Execute(IniRead($__SettingsFile, 'encryption', 'enabled', 'false'))
Global Const $__EncryptionKeyOrFile = IniRead($__SettingsFile, 'encryption', 'keyOrFile', '')
Global Const $__EncryptionAlgorithm = Execute('$' & IniRead($__SettingsFile, 'encryption', 'algorithm', 'CALG_AES_256'))

#include "Server Resources\Core.au3"

__Init()