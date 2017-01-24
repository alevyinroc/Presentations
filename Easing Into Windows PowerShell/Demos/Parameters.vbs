function DoStuff(AppEnvironment)
	ValidEnvironments = Array("dev", "test", "prod")
	If Ubound(Filter(ValidEnvironments, AppEnvironment)) > -1 Then
		WScript.Echo("This is valid")
    Else
		WScript.Echo(AppEnvironment + " is not a valid value")
    End If
end function

DoStuff("huh?")