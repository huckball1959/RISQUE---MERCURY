@echo off
setlocal

:: Set folder to current directory
set "folder=%CD%"
:: Get timestamp for unique log file
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,8%%dt:~8,4%"
set "output=%folder%\combined.txt"
set "log=%folder%\merge_log_%timestamp%.txt"

:: Clear existing combined.txt and old logs
if exist "%output%" del "%output%"
for %%F in ("%folder%\merge_log_*.txt") do del "%%F"

:: Create log file
echo Debug Log - %date% %time% > "%log%"

:: Check if folder exists
if not exist "%folder%" (
    echo Error: Folder %folder% does not exist >> "%log%"
    echo Error: Folder %folder% does not exist
    echo Please verify the path and try again
    pause
    exit /b
)

:: Log all files in folder
echo Listing all files in %folder%... >> "%log%"
dir "%folder%" /b >> "%log%"
echo. >> "%log%"

:: Log files with .html, .js, .css extensions
echo Checking for .html, .js, .css files... >> "%log%"
powershell -Command "Get-ChildItem -Path '%folder%\*' -Include *.html,*.js,*.css -File | ForEach-Object { $_.Name } | Out-File -FilePath '%log%' -Append -Encoding UTF8"
powershell -Command "$count = (Get-ChildItem -Path '%folder%\*' -Include *.html,*.js,*.css -File).Count; 'Found ' + $count + ' files' | Out-File -FilePath '%log%' -Append -Encoding UTF8"

:: Run PowerShell to merge files
powershell -Command "$files = Get-ChildItem -Path '%folder%\*' -Include *.html,*.js,*.css -File; if ($files.Count -eq 0) { 'Error: No .html, .js, or .css files found' | Out-File -FilePath '%log%' -Append -Encoding UTF8; exit 1 }; foreach ($file in $files) { '// ----- ' + $file.Name + ' -----' | Out-File -FilePath '%output%' -Append -Encoding UTF8; Get-Content $file.FullName -Raw | Out-File -FilePath '%output%' -Append -Encoding UTF8; '' | Out-File -FilePath '%output%' -Append -Encoding UTF8 }"
if errorlevel 1 (
    echo Error: Failed to create combined.txt
    echo Check %log% for details
    pause
    exit /b
)

:: Check if the output file was created
if exist "%output%" (
    echo Merge completed! Check %output%
    echo Log saved to %log%
) else (
    echo Error: Failed to create combined.txt
    echo Check %log% for details
)

pause