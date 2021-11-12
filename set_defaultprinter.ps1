# Written by J. Patton to mitigate the default printer not mapping correctly for users.
#Pause for 15 seconds
Start-Sleep 15
# import the containing assembly
Add-Type -AssemblyName System.IO.Compression.FileSystem

try{
  # open the zip file with ZipFile
  $zipFileItem = Get-Item $ENV:UEMProfileArchives"\Windows Settings\Default Printer.zip"
  $zipFile = [System.IO.Compression.ZipFile]::OpenRead($zipFileItem.FullName)

  # find the desired file entry
  $compressedFileEntry = $zipFile.Entries |Where-Object Name -eq 'Default Printer.xml'

  # read the first 100kb of the file stream:
  $buffer = [byte[]]::new(100KB)
  $stream = $compressedFileEntry.Open()
  $readLength = $stream.Read($buffer, 0, $buffer.Length)
}
finally{
  # clean up
  if($stream){ $stream.Dispose() }
  if($zipFile){ $zipFile.Dispose() }
}

if($readLength){
  $xmlString = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $readLength)
    $found = $xmlstring -match '.*<defaultPrinter name="(.*)"/>.*'
    if ($found) {
        $printer = $matches[1]
    (New-Object -ComObject WScript.Network).AddWindowsPrinterConnection($printer)
    (New-Object -ComObject WScript.Network).SetDefaultPrinter($printer)
    }
   
}
else{
  Write-Warning "Failed to extract partial xml string"
}
