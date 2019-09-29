#include <Crypt.au3>


If Not FileExists("key.txt") Then
	FileWrite("key.txt", _Crypt_DeriveKey("My super Secret password", $CALG_AES_256))
	MsgBox(0, "", "Key created successfully")
	Exit
Else
	MsgBox(0, "", "key.txt already exists, remove it to generate a new key")
EndIf



