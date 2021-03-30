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
    $newlines_count_header = $newlines_count_header - 4 # remove the newlines used in the debugging-comment
    $programcs = "/* DEBUGGING ENABLED:`nThe newlines before the real code are to adjust error-messages`nto reflect the error-positions in your real source-code!`nSo don't remove them or you will get wrong hints.`nExecute 'extract_script.ps1 -Debugging `$false' to remove everything unneeded.*/" + "".PadRight($newlines_count_header, "`n") + $programcs
} else { # Minimize
    $programcs = $programcs.Substring($programcs_header_end, $programcs_footer_start - $programcs_header_end) # extract body
    [int] $indention = 8
    [regex] $regex = "(?ms)^[\s]{${indention}}|[\s^`n]+`$|[\s]+[/]{2}[^`n]+"; # search for: multiple new-lines, indentions, spaces at EOL, single-line comments
    $programcs = $regex.Replace($programcs, ""); # remove everything found by the regex above
}

Set-Content -Path ..\Script.cs -Value $programcs
