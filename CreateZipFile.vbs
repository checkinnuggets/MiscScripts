'  Back in the day, Windows Server 2003 didn't have a built in zip file utility.
'  It had a the ability to create/extract archives from built into the shell,
' but there wasn't an exe, so you to create a zip from the command line.

' At the time I was working at a place with crazy security restrictions which
' meant I couldn't get a program installed, but they had no problem with me
' messing about with vbscript.  

' I remember spending time researching how to solve this, but I'm not sure how
' much of this I wrote myself or whether I found the whole thing and just started
' using it, so if this was yours please tell me and I will give you full credit.

Sub Main()

	' Usage/Parameters
	If (Wscript.Arguments.Count <> 2) Then  
		Wscript.Echo "Usage is cscript CreateZip.vbs <SourceDir> <OutFile>"  
		Wscript.Quit  
	End If  
	
	vSrcDir = Wscript.Arguments(0)
	vOutFile = Wscript.Arguments(1)  
	
	Set fso = CreateObject("Scripting.FileSystemObject")
	
	' Check Source Folder
	If ( fso.FolderExists(vSrcDir) ) Then
		Wscript.Echo "Source Directory: "  & vSrcDir
	Else
		Wscript.Echo "Source directory does not exist."  
		Wscript.Quit
	End If
	
	' ZIP extension on Output File
	If( Right(vOutFile, 4) <> ".zip" ) Then
		vOutFile = vOutFile + ".zip"
	End If
	
	CreateZipFile( vOutFile )
	CopyToZipFile vSrcDir, vOutFile

End Sub

' Method which recursively copies files to a zip file
Sub CopyToZipFile(SourcePath, ZipFileName)

	Wscript.Echo "Source: " & SourcePath
	Wscript.Echo "Destination: " & ZipFileName

	' get folder object
	Set oFolder = CreateObject("Scripting.FileSystemObject").GetFolder(SourcePath)
	
	' Add SubFolders
	For Each oSubDir in oFolder.SubFolders
		Wscript.Echo "Adding Folder: " & oSubDir.name
		With CreateObject("Shell.Application")
			.NameSpace(ZipFileName).CopyHere oFolder & "\" & oSubDir.name
		End With
	Next
	
	' Add Files
	For Each oFile in oFolder.Files
		
		Wscript.Echo "Adding File: " & oFile.name		
		
		With CreateObject("Shell.Application")
			.NameSpace(ZipFileName).CopyHere oFolder & "\" & oFile.name
		End With
		
	Next	
	
End Sub

Sub CreateZipFile(ZipFileName)

	Wscript.Echo "Creating " & ZipFileName

	Set fso = CreateObject("Scripting.FileSystemObject")
	
	If Not fso.FileExists(ZipFileName) Then
		fso.CreateTextFile(ZipFileName, True).Write "PK" & Chr(5) & Chr(6) & String(18, vbNullChar)	
	End If
			
End Sub

' Method used to check whether a zip file has been created
Sub WaitForFile(ZipFileName)

	fZipIsFinished=0
	Set fs = CreateObject("Scripting.FileSystemObject")

	While fZipIsFinished=0
		
		' the file created empty is 22 bytes.  If the file is created, accessible and not 22 bytes, the process is complete		
		If fs.FileExists(ZipFileName) Then

			Set h=fs.getFile(ZipFileName)
			
			'msgbox ZipFileName & " " & fZipIsFinished
			If h.size=22 Then
				fZipIsFinished=0			
			Else
				fZipIsFinished=1
			End If
				
		Else			
			fZipIsFinished=0
		End If
				
		wScript.Sleep 1000	'wait before looping again
	Wend

End Sub

Main()


