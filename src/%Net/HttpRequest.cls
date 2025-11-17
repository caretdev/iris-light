Class %Net.HttpRequest Extends %RegisteredObject
{

Method %DispatchGetProperty(propertyName As %String)
{
  quit ""
}

Method %DispatchSetProperty(propertyName As %String(MAXLEN=""), value As %String(MAXLEN=""))
{
  quit ""
}

Method Get(location As %String = "", test As %Integer = 0, reset As %Boolean = 1) As %Status
{
  quit $$$ERROR($$$NotImplemented)
}

}
