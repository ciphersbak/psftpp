'/**
'* This VBScript is used to check if Application Designer is already open. If Application
'* Designer is already open then just Activate that window and then open the respective
'* object. But if Application Designer is not previously open, then it opens that. Once
'* Developer has entered User ID and Password, then the respective object will be open
'* in the Application Designer.
'*
'* @version     : 1.0
'* @author      : Prashant Prakash
'* @date        : 06/14/3013
'*
'* -- ** PLEASE DO NOT EDIT / DELETE THIS VBSCRIPT FILE ** -- *
'*/

' Declaring all the variables
Dim oWScriptShell, oWindowsManagementService, oAllArguments, Process
Dim boolIsApplicationDesignerRunning, nbrLoopCounter, keyTAB, psObjName

' Getting the handle for Windows Management functions
Set oWindowsManagementService = GetObject ("winmgmts:")
Set oWScriptShell = CreateObject("WScript.Shell")

' Assuming that Application Designer is not running by default
boolIsApplicationDesignerRunning = "False"

' If Application Designer process is running then try to select that Application, but if
' unable to select then raise exception
For Each Process In oWindowsManagementService.InstancesOf ("Win32_Process")
	If Process.Name = "pside.exe" then
		If Not oWScriptShell.AppActivate("Application Designer") Then
			oAppActivateReturnValue = "False"
			nbrLoopCounter = 1
			keyTAB = ""
			
			' Just maximizing all the windows, so that the process can select Application Designer
			Do While oAppActivateReturnValue = "False" and nbrLoopCounter <= 20
				keyTAB = keyTAB & "{TAB}"
				oWScriptShell.SendKeys "%(" & keyTAB & ")"
				oWScriptShell.SendKeys "% x" 
				nbrLoopCounter = nbrLoopCounter + 1
				oAppActivateReturnValue = oWScriptShell.AppActivate("Application Designer")
			Loop
			
			' If unable to select Application Designer, then raise exception
			If oAppActivateReturnValue = "False" Then
				WScript.Echo "Make sure Application Designer is not Minimized."
				WScript.Quit
			End If
		End If
		boolIsApplicationDesignerRunning = "True"
	End If
Next
If boolIsApplicationDesignerRunning = "False" Then
	
	' Since Application Designer is not running, start it up
	oWScriptShell.Run "pside.exe", 3, False
	oAppActivateReturnValue = "False"
	Do While oAppActivateReturnValue = "False"
		oAppActivateReturnValue = oWScriptShell.AppActivate("Application Designer")
	Loop
End If

' Confirm once again, if Application Designer is running, and if running then you
' are set to go. But just in case if it is not running then JUST QUIT!
If Not oWScriptShell.AppActivate("Application Designer") Then
	WScript.Echo "Unable to find Application Designer, hence Quiting..."
	WScript.Quit
End If

Set oAllArguments = WScript.Arguments
' Store the arguments in a variable:
Set objArgs = Wscript.Arguments
For I = 0 to objArgs.Count - 1
  Wscript.Echo objArgs(I)
Next

oWScriptShell.AppActivate("Application Designer")
' Just creating a PeopleSoft Application Designer type of object
Set IDE = CreateObject("PeopleSoft.ApplicationDesigner")
oWScriptShell.AppActivate("Application Designer")

' This is required because, in case of Internet Explorer there is a "/" at the end, so
' using this, I am just removing that last string(if present offcourse)
nbrSlashLocation = Len(oAllArguments(0))
If InStr(9, oAllArguments(0), "/") > 0 Then
	nbrSlashLocation = Len(oAllArguments(0)) - 1
End If
psObjName = Mid(oAllArguments(0), 9, nbrSlashLocation - 8)

IDE.ViewObject(psObjName)
