[int] $maximumFilesize = 100000
[int] $scriptFilesize = (Get-ChildItem -Path ..\Script.cs).length

if ($scriptFilesize -gt $maximumFilesize) {
    throw "The script has more than ${maximumFilesize} bytes in size (currently: ${scriptFilesize}) and might not be loaded by Space Engineers.`n`
        Try reducing the number of bytes by using 'extract_script.ps1 -Debugging `$false'`n`
        or/and optimizing the code or/and removing unnecessary code or/and shorten variable names."
} else {
    [float] $ratio = $scriptFilesize / $maximumFilesize
    [string] $ratioPercentage = [math]::Round($ratio, 4) * 100
    Write-Host "Current script size is: ${scriptFilesize} bytes (${ratioPercentage} % of ${maximumFilesize} bytes)"
}