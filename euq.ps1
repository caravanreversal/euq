# CONSTANT
$historyPath = ".\history.txt"

# CLI
$qlikServer = $args[0]
$username = $args[1]
$extName = $args[2]
$extPath = $args[3]
$zipPath = $args[4]


# i don't use it
function generateWBL {
    # remove the existing wbfolder.wbl (if exists)
    Remove-Item .\$extName\wbfolder.wbl -ErrorAction Ignore

    # list all files under the src folder and add them to the wbl file
    $existingFiles = Get-ChildItem -Path .\$extName -File |
        foreach {$_.name} > .\$extName\wbfolder.wbl
}

function compressFolder{
    # archive the content of the src folder
    $7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"
    Set-Alias Start-SevenZip $7zipPath
    Start-SevenZip a -mx=9 $zipPath\$extName.zip $extPath\$extName\* | out-null
    
    Write-Host "ZIP file created"
}

function connectQlik {
    ## connect to Qlik using Qlik-CLI
    Get-ChildItem cert:CurrentUser\My | Where-Object { $_.FriendlyName -eq 'QlikClient' } | 
        Connect-Qlik -computerName "$qlikServer" -username "$username" -TrustAllCerts | out-null
    Write-Host "Connected to Qlik"
}

function removeOldExtVersion {
    # Query Qlik for extension with the same name
    $ext = Get-QlikExtension -Filter "name eq '$extName'" | Measure-Object

    # if there is such extension - delete it
    if ( $ext.Count -gt 0) {
        Remove-QlikExtension -ename "$extName" | out-null
        Write-Host "Older version found and removed"
    }
}

function importExtension {
    # Import the archive for the build folder
    Import-QlikExtension -ExtensionPath "$zipPath\$extName.zip" | out-null
    Write-Host "New version was imported"
}

function storeHistory {
    $propertiesExt = "$qlikServer;$username;$extName;$extPath;$zipPath"
    $isRepeated = "f"

    # Before save check if same line exist
    If(Test-Path -Path $historyPath -PathType Leaf) {   
        ForEach ($item in (Get-Content -Path $historyPath)) {
            if( $item -eq $propertiesExt ){
                $isRepeated = "y"
                break;
            }
        } 
    } 
    if ( $isRepeated -eq "f" ) {
        $propertiesExt | Out-File -FilePath $historyPath -Append 
    }
}

function main {
  compressFolder
  connectQlik
  removeOldExtVersion
  importExtension
  storeHistory
  endPs
}
function manualInput {    
    $qlikServer = Read-Host -Prompt 'Enter qlik server' 
    $username   = Read-Host -Prompt 'Enter username' 
    $extName    = Read-Host -Prompt 'Enter extension name' 
    $extPath    = Read-Host -Prompt 'Enter extension path' 
    $zipPath    = Read-Host -Prompt 'Enter zip path' 

    main
}
function checkHistory { 
    If(Test-Path -Path $historyPath -PathType Leaf) {   
        $counter = 1
        ForEach ($item in (Get-Content -Path $historyPath)) {
            Write-Host "  "$counter": " $item
            $counter++
        } 
        $historyOption = Read-Host -Prompt 'Select option' 

        selectHistory
    } else { 
        Write-Host "No 'history.txt' file available"
        endPs
    }
}

function selectHistory {
    $counter = 1
    $historyFound = 'f'
    ForEach ($item in (Get-Content -Path $historyPath)) {
        if ($counter -eq $historyOption){
            $historyFound = 't'
            $valuesArr  = $item.split(';')

            $qlikServer = $valuesArr[0]
            $username   = $valuesArr[1]
            $extName    = $valuesArr[2]
            $extPath    = $valuesArr[3]
            $zipPath    = $valuesArr[4]

            main 

            break;
        }

        $counter++
    } 
    if ($historyFound -eq 'f'){
        Write-Host Index not found
        endPs
    }
}

function help {
   Write-Host "Command usage CLI: .\euq.ps1 'qlik_server' 'domain\user' 'ext_name' 'zip_path'"
   
   endPs
}

function delHistory{
    If(Test-Path -Path $historyPath -PathType Leaf) {
        Write-Host "Are you sure you want to delete the history file?"
        $deleteFileBool = Read-Host -Prompt '[y/n]' 
        If ($deleteFileBool -eq 'y'){
            Remove-Item -Path $historyPath
        }
    } else { Write-Host "No 'history.txt' file available" }
    endPs
}

function endPs {
    Write-Host END
}

function showMenu {
    Write-Host "Menu:"
    Write-Host "  1: Manual input"
    If(Test-Path -Path $historyPath -PathType Leaf) {
        Write-Host "  2: History"
        Write-Host "  3: Clear history"
    } else {    
        Write-Host "  2: History (Disabled)"
        Write-Host "  3: Clear history (Disabled)"
    }
    # Check if history file exist
    Write-Host "  4: Help"
    Write-Host "  5: End"

    $menuOption = Read-Host -Prompt 'Select option' 

    
    switch ($menuOption)
    {
        1 {manualInput}
        2 {checkHistory}
        3 {delHistory}
        4 {help}
        5 {endPs}
        default {
            Write-Host Option not found
            endPs
        }
    }
}

if ( $args.count -eq 5 ) {
    main
} else {
    showMenu
}