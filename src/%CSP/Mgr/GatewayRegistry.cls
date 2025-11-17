Class %CSP.Mgr.GatewayRegistryImpl Extends %RegisteredObject
{

Method GetGatewayMgrs(type As %String = "a") As %ListOfObjects
{
  quit ##class(%ListOfObjects).%New()
}

Method RemoveFilesFromCaches(listOfFilenames As %List = "", type As %String = "a") As %Status
{
  quit $$$OK
}

}
