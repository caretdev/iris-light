Class %Library.EnsembleMgr [ System = 4 ]
{

ClassMethod IsEnsembleInstalled() As %Boolean [ CodeMode = expression ]
{
0
}

ClassMethod IsDICOMInstalled() As %Boolean [ CodeMode = expression ]
{
0
}

ClassMethod IsHealthShareInstalled() As %Boolean  [ CodeMode = expression ]
{
0
}

ClassMethod IsEnsembleNamespace(pNamespace = {$namespace}) As %Boolean [ CodeMode = expression ]
{
0
}

ClassMethod OnSystemStartup(Output pConsoleLog As %String, pIsStartup As %Boolean = 0) As %Boolean
{
  kill pConsoleLog
  set pConsoleLog = 0
  quit 1
}

ClassMethod OnSystemShutdown(Output pConsoleLog As %String, Output pCancelShutdown As %Boolean) As %Boolean
{
  kill pConsoleLog
  set pConsoleLog = 0
  set pCancelShutdown = 0
  quit 1
}

ClassMethod CheckForInstall()
{
}

ClassMethod Install(args...) As %Status [ CodeMode = expression ]
{
1
}

ClassMethod ValidateEnsemble(args...) As %Status [ CodeMode = expression ]
{
1
}

}
