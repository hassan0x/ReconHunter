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
