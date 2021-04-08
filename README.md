# Short description

A template-project for creating VS-Solutions for development of in-game-scripts in Space Engineer with VSCode.

# Creating a new project for a Space Engineers in-game-script

Open PowerShell in the folder, where `setup.ps1` resides and call `setup.ps1`.

    .\setup.ps1
        [[-SpaceEngineersBinPath] <string>]
        [[-OutputPath] <string>]
        [[-ProjectName] <string>]

This will create a new folder at `OutputPath` with VS-Solutions, -Project files and everything you need to implement your Space Engineers in-game-script with VSCode.

## Parameter SpaceEngineersBinPath

This is an optional argument. Default: `${env:ProgramFiles(x86)}\Steam\steamapps\common\SpaceEngineers\Bin64`

It will define the directory, where your Space Engineers binaries are found.

If not given thru `settings.ps1`, a path selection dialog will open up on execution.

## Parameter OutputPath

This is an optional argument. Default: `${env:APPDATA}\SpaceEngineers\IngameScripts\local`

It will define the directory, where your Space Engineers scripts will be placed in subfolders.

If not given thru `settings.ps1`, a path selection dialog will open up on execution.

## Parameter ProjectName

This is an optional argument.

It will define the name of the project. This will also be the name of the subdirectory in `OutputPath`.

If not given as an argument, the script `setup.ps1` will ask you for it.

## settings.ps1

Once the script `setup.ps1` got values for `SpaceEngineersBinPath` and `OutputPath`, it will write a `settings.ps1` aside it.

The next times the script executes, it will read it to set `SpaceEngineersBinPath` and `OutputPath` automatically.

# Structure of files of a created project

    ${OutputPath}\${ProjectName}
        +- src\
            +- ${ProjectName}.sln
            +- Program.cs
            +- SpaceEngineers.csproj
            +- thumb.png
            +- check_size.ps1
            +- extract_script.ps1
            ...
        +- Script.cs (created by extract_script.ps1)

# Tools used in the build tasks in the created project

This project contains tools that will be used in the build process.

## extract_script.ps1

    .\extract_script.ps1
        [[-Debugging] <bool>]

This script will extract the relevant source-code (between the regions `Header` and `Footer`) from the `Program.cs` and place it in `../Script.cs`.

### Parameter Debugging

This is an optional argument. Default: `$true`

It will define to create debug-code (if set to `$true`) or release-code (otherwise) in the resulting `Script.cs`.

### debug-code vs. release-code

debug-code

* will keep the line-numbers and character-positions
* will contain everything (code, comments, etc.) between the regions in `Program.cs`
* is bigger in byte-size

Example of running for debug-code:

    WARNING: Debugging has been enabled, which will have a bigger script size, as without it.
        If you want to share the final script, deactivate debugging with providing -Debugging $false.

release-code

* will not contain empty lines
* will not contain single-line comments (multi-line comments will in the result)
* is smaller in byte-size
* is still readable by others (can be reformatted with VSCode)

Example of running for release-code:

    Release-mode is activated. This will reduce the script-size by removing non-vital data from it.
        Original: 5913 bytes, Minimized: 4747 bytes, Saved: 1166 bytes, Ratio: 80.28 %

## check_size.ps1

    .\check_size.ps1

This script will read the size of the file `..\Script.cs` and print the remaining size in bytes and percentage.

Example of success:

    Current script size is: 5939 bytes (5.94 % of 100000 bytes)

It will throw an error if the size of `..\Script.cs` is greater than allowed.

Example of failure:

    The script has more than 100000 bytes in size (currently: 102746) and might not be loaded by Space Engineers.
            Try reducing the number of bytes by using 'extract_script.ps1 -Debugging $false'
            or/and optimizing the code or/and removing unnecessary code or/and shorten variable names.
    In ...\src\check_size.ps1:5 Zeichen:5
    +     throw "The script has more than ${maximumFilesize} bytes in size  ...
    +     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : OperationStopped: (The script has ...variable names.:String) [], RuntimeException
        + FullyQualifiedErrorId : The script has more than 100000 bytes in size (currently: 102746) and might not be loaded by Space Engineers.
            Try reducing the number of bytes by using 'extract_script.ps1 -Debugging $false'
            or/and optimizing the code or/and removing unnecessary code or/and shorten variable names.

# Build tasks in the created project

There are two build tasks defined for usage in VSCode: `build: debug` and `build: release`.

*`Ctrl`+ `Shift` + `b` will call `build: debug` only.*

*To execute the tasks with one click, I recommend to install the VSCode-extension `Task Runner`. The version of `sanaajani.taskrunnercode` is working for me.*

Both will create the target folder (if not existing; defined with `project.output.script.dir` in `.vscode\settings.json`; default: `${env:APPDATA}/SpaceEngineers/IngameScripts/local/${ProjectName}/`), execute `.\extract_script.ps1` (which will create `..\Script.cs`), execute `.\check_size.ps1` (which will check `..\Script.cs`) and copy the files `..\Script.cs` and `.\thumb.png` to the target folder.

`build: debug` will call `.\extract_script.ps1` with `-Debugging $true`, while `build: release` will call it with `-Debugging $false`.