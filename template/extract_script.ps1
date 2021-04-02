param (
    [Parameter()][bool] $Debugging = $true
)

[string] $programcs = Get-Content -Path .\Program.cs -Raw

[int] $programcs_header_end = $programcs.IndexOf("#endregion") + "#endregion".Length
[int] $programcs_footer_start = $programcs.LastIndexOf("#region")

if ($Debugging) {
    # Keep empty lines before body, because then you will have correct linenumbers on stacktraces and error-messages.
    [int] $newlines_count_header = $programcs.Substring(0, $programcs_header_end).Split("`n").Count - 1
    $programcs = $programcs.Substring($programcs_header_end, $programcs_footer_start - $programcs_header_end) # extract body
    $programcs = "".PadRight($newlines_count_header, "`n") + $programcs
    Write-Host "WARNING: Debugging has been enabled, which will have a bigger script size, as without it.`
        If you want to share the final script, deactivate debugging with providing -Debugging `$false."
} else { # Minimize
    $programcs = $programcs.Substring($programcs_header_end, $programcs_footer_start - $programcs_header_end) # extract body
    [int] $originalSize = $programcs.Length
    [int] $indention = 8
    [regex] $regex = "(?ms)^[\s]{${indention}}|[\s^`n]+`$|[\s]+[/]{2}[^`n]+"; # search for: multiple new-lines, indentions, spaces at EOL, single-line comments
    $programcs = $regex.Replace($programcs, ""); # remove everything found by the regex above
    [int] $minimizedSize = $programcs.Length
    [int] $savedSize = $originalSize - $minimizedSize
    [float] $savedRatio = $minimizedSize / $originalSize
    [string] $ratioPercentage = [math]::Round($savedRatio, 4) * 100
    Write-Host "Release-mode is activated. This will reduce the script-size by removing non-vital data from it.`
        Original: ${originalSize} bytes, Minimized: ${minimizedSize} bytes, Saved: ${savedSize} bytes, Ratio: ${ratioPercentage} %"
}

Set-Content -Path ..\Script.cs -Value $programcs
