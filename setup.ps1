param(
    [string] $SpaceEngineersBinPath,
    [string] $OutputPath,
    [string] $ProjectName
)

if ($null -eq $SpaceEngineersBinPath -or $SpaceEngineersBinPath.Length -eq 0) {
    try {
        . (".\settings.ps1")
    } catch {
        function Show-Folder-Selection-Dialog([string] $Description, [string] $SelectedPath) {   
            [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        
            [System.Windows.Forms.FolderBrowserDialog] $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $dialog.Description = $Description
            $dialog.ShowNewFolderButton = $true
            $dialog.SelectedPath = $SelectedPath
            $dialog.ShowDialog() | Out-Null
        
            return $dialog.SelectedPath
        }

        if ($null -eq $SpaceEngineersBinPath -or $SpaceEngineersBinPath.Length -eq 0) {
            [string] $default = "${env:ProgramFiles(x86)}\Steam\steamapps\common\SpaceEngineers\Bin64"
            $SpaceEngineersBinPath = Show-Folder-Selection-Dialog -Description "Select the binary directory of SpaceEngineers`nDefault: ${default}" -SelectedPath $default
            Remove-Variable -Name default
        }

        if ($null -eq $OutputPath -or $OutputPath.Length -eq 0) {
            [string] $default = "${env:APPDATA}\SpaceEngineers\IngameScripts\local"
            $OutputPath = Show-Folder-Selection-Dialog -Description "Select the path to the output folder`nDefault: ${default}" -SelectedPath $default
            Remove-Variable -Name default
        }
    }
}

Write-Host "Selected game binary folder: '$SpaceEngineersBinPath'"
Write-Host "Selected output folder: '${OutputPath}'"

Set-Content -Path .\settings.ps1 -Value "`$SpaceEngineersBinPath = `"$SpaceEngineersBinPath`"`n`$OutputPath = `"$OutputPath`""

while ($ProjectName.Length -eq 0) {
    $ProjectName = Read-Host -Prompt "Input the project name"
}
Write-Host "Selected project name: '${ProjectName}'"

$OutputPath = "${OutputPath}\${ProjectName}\src"
Write-Host "Final output path: ${OutputPath}"

# Create solution directory and change to it
mkdir -Path $OutputPath -Force

$csproj = (Get-Content -Path .\template\SpaceEngineers.csproj -Raw) -replace 'SpaceEngineersBinPath',$SpaceEngineersBinPath
Set-Content -Path $OutputPath\SpaceEngineers.csproj -Value $csproj
Remove-Variable -Name csproj

if (!(Test-Path $OutputPath\Program.cs -PathType leaf)) {
    [string] $programcs = (Get-Content -Path .\template\Program.cs -Raw) -replace 'ProjectName',$ProjectName

    if (Test-Path $OutputPath\..\Script.cs -PathType leaf) {
        [int] $programcs_header_end = $programcs.IndexOf("#endregion") + "#endregion".Length
        [int] $programcs_footer_start = $programcs.LastIndexOf("#region")
        [string] $scriptcs = Get-Content -Path $OutputPath\..\Script.cs -Raw
        [int] $indention = 8
        $programcs = $programcs.Substring(0, $programcs_header_end) + "`n`n" + "".PadRight($indention, ' ') + $scriptcs.Replace("`n", "`n" + "".PadRight($indention, ' ')) + "`n`n" + $programcs.Substring($programcs_footer_start)

        Remove-Variable -Name scriptcs
    }
    
    Set-Content -Path $OutputPath\Program.cs -Value $programcs
    Remove-Variable -Name programcs
} else {
    Write-Host "WARNING: $OutputPath\Program.cs already exists and will not be overwritten." -ForegroundColor Yellow
}

Copy-Item -Path .\template\.gitignore -Destination $OutputPath\

if (!(Test-Path $OutputPath\thumb.png -PathType leaf)) {
    Copy-Item -Path .\template\thumb.png -Destination $OutputPath\
} else {
    Write-Host "WARNING: $OutputPath\thumb.png already exists and will not be overwritten." -ForegroundColor Yellow
}

Set-Location -Path $OutputPath 
# Create relevant solution and project files
dotnet new sln -n ${ProjectName} --force
dotnet sln add .\SpaceEngineers.csproj