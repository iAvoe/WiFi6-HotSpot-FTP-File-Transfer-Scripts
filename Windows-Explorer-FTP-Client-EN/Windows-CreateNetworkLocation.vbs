' Credit: (MC ND, Andrew Morton) https://stackoverflow.com/questions/30912161/add-new-network-location-not-map-network-drive

Option Explicit

Function CreateNetworkLocation( networkLocationName, networkLocationTarget )
    Const ssfNETHOOD  = &H13&
    Const fsATTRIBUTES_READONLY = 1
    Const fsATTRIBUTES_HIDDEN = 2
    Const fsATTRIBUTES_SYSTEM = 4

    CreateNetworkLocation = False 

    ' Instantiate needed components
    Dim fso, shell, shellApplication
        Set fso =               WScript.CreateObject("Scripting.FileSystemObject")
        Set shell =             WScript.CreateObject("WScript.Shell")
        Set shellApplication =  WScript.CreateObject("Shell.Application")

    ' Locate where NetworkLocations are stored
    Dim nethoodFolderPath, networkLocationFolder, networkLocationFolderPath
        nethoodFolderPath = shellApplication.Namespace( ssfNETHOOD ).Self.Path

    ' Create the folder for our NetworkLocation and set its attributes
        networkLocationFolderPath = fso.BuildPath( nethoodFolderPath, networkLocationName )
        If fso.FolderExists( networkLocationFolderPath ) Then 
            Exit Function 
        End If 
        Set networkLocationFolder = fso.CreateFolder( networkLocationFolderPath )
        networkLocationFolder.Attributes = fsATTRIBUTES_READONLY

    ' Write the desktop.ini inside our NetworkLocation folder and change its attributes    
    Dim desktopINIFilePath
        desktopINIFilePath = fso.BuildPath( networkLocationFolderPath, "desktop.ini" )
        With fso.CreateTextFile(desktopINIFilePath)
            .Write  "[.ShellClassInfo]" & vbCrlf & _ 
                    "CLSID2={0AFACED1-E828-11D1-9187-B532F1E9575D}" & vbCrlf & _ 
                    "Flags=2" & vbCrlf
            .Close
        End With 
        With fso.GetFile( desktopINIFilePath )
            .Attributes = fsATTRIBUTES_HIDDEN + fsATTRIBUTES_SYSTEM
        End With 

    ' Create the shortcut to the target of our NetworkLocation
    Dim targetLink
        targetLink = fso.BuildPath( networkLocationFolderPath, "target.lnk" )
        With shell.CreateShortcut( targetLink )
            .TargetPath = networkLocationTarget
            .Save
        End With        

    ' Done
        CreateNetworkLocation = True 

End Function

' Main script logic to handle parameters
Dim networkLocationName, networkLocationTarget
If WScript.Arguments.Count < 2 Then
    WScript.Echo "Usage: script.vbs networkLocationName networkLocationTarget"
    WScript.Quit 1
End If

networkLocationName = WScript.Arguments(0)
networkLocationTarget = WScript.Arguments(1)

If CreateNetworkLocation(networkLocationName, networkLocationTarget) Then
    WScript.Echo "Network location created successfully."
Else
    WScript.Echo "Failed to create network location."
End If