Class DataMove.Data Extends %RegisteredObject
{

ClassMethod Shutdown(WaitSeconds As %Integer = 0) As %Status [ Internal ]
{
  quit $$$OK
}

ClassMethod STUStartup(ByRef Reverted As %Boolean) As %Status [ Internal ]
{
  set Reverted = 0
  quit $$$OK
}

ClassMethod STURestart(Mirror = 0) As %Status [ Internal ]
{
  quit $$$OK
}

ClassMethod GetEarliestJRNCUR(ByRef JournalFile As %String, ByRef Name As %String) As %Status [ Internal ]
{
  set JournalFile = ""
  quit $$$OK
}

}
