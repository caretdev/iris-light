Class %Net.Remote.Gateway Extends %RegisteredObject
{

ClassMethod %TerminateAllSuperServers() [ Final ]
{
}

Method %Shutdown(timeout = 0) As %Status [ Final ]
{
  quit 1
}

}